"""Repeatable upload-endpoint evaluator for Model A v2 and regression checks.

Exercises the actual multipart classification endpoint (`classify-fish`) against
real local checkpoints using an isolated in-memory SQLite database so normal
scan history and telemetry are never modified.
"""

import argparse
import json
import mimetypes
import os
import sys
from pathlib import Path
from unittest.mock import patch

BACKEND_DIR = Path(__file__).resolve().parent.parent
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")

import django  # noqa: E402
from django.core.files.uploadedfile import SimpleUploadedFile  # noqa: E402
from django.core.management import call_command  # noqa: E402
from django.test.utils import override_settings  # noqa: E402
from django.urls import reverse  # noqa: E402

DEFAULT_REGRESSION_CASES = [
    {
        "name": "unrelated3_eye",
        "image_path": str(BACKEND_DIR / "ml" / "challenge_images" / "unrelated_objects" / "unrelated3.png"),
        "expected_category": "unsupported",
        "region_type": "eye",
        "group": "regression",
    },
    {
        "name": "unrelated3_gill",
        "image_path": str(BACKEND_DIR / "ml" / "challenge_images" / "unrelated_objects" / "unrelated3.png"),
        "expected_category": "unsupported",
        "region_type": "gill",
        "group": "regression",
    },
    {
        "name": "asean_illustration_eye",
        "image_path": str(BACKEND_DIR / "ml" / "challenge_images" / "unrelated_objects" / "asean_illustration.png"),
        "expected_category": "unsupported",
        "region_type": "eye",
        "group": "regression",
    },
    {
        "name": "asean_illustration_gill",
        "image_path": str(BACKEND_DIR / "ml" / "challenge_images" / "unrelated_objects" / "asean_illustration.png"),
        "expected_category": "unsupported",
        "region_type": "gill",
        "group": "regression",
    },
]


def _setup_isolated_django():
    django.setup()
    from django.db import connections

    connections.databases["default"] = {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": ":memory:",
        "ATOMIC_REQUESTS": False,
        "AUTOCOMMIT": True,
        "CONN_MAX_AGE": 0,
        "CONN_HEALTH_CHECKS": False,
        "OPTIONS": {},
        "TIME_ZONE": None,
        "USER": "",
        "PASSWORD": "",
        "HOST": "",
        "PORT": "",
        "TEST": {"NAME": None},
    }
    call_command("migrate", verbosity=0, interactive=False)


def _guess_content_type(path: Path) -> str:
    guessed, _ = mimetypes.guess_type(str(path))
    return guessed or "image/png"


def evaluate_cases(cases, validator_checkpoint=None):
    from classification import views as classification_views
    from rest_framework.test import APIClient

    client = APIClient()
    url = reverse("classify-fish")

    override_kwargs = {"ALLOWED_HOSTS": ["testserver", "localhost", "127.0.0.1"]}
    if validator_checkpoint:
        override_kwargs["VALIDATOR_CANDIDATE_PATH"] = str(validator_checkpoint)

    results = []
    missing_files = []

    with override_settings(**override_kwargs):
        for case in cases:
            img_path = Path(case["image_path"])
            if not img_path.is_file():
                missing_files.append(
                    {
                        "name": case.get("name", img_path.name),
                        "image_path": str(img_path),
                        "expected_category": case["expected_category"],
                        "region_type": case["region_type"],
                        "group": case.get("group", "held_out"),
                    }
                )
                continue

            raw_bytes = img_path.read_bytes()
            uploaded = SimpleUploadedFile(
                img_path.name,
                raw_bytes,
                content_type=_guess_content_type(img_path),
            )

            with patch.object(
                classification_views,
                "predict_image",
                wraps=classification_views.predict_image,
            ) as predict_spy:
                response = client.post(
                    url,
                    {"image": uploaded, "region_type": case["region_type"]},
                    format="multipart",
                )
                model_b_ran = predict_spy.called

            payload = {}
            try:
                payload = response.json()
            except Exception:
                payload = {}

            if response.status_code == 200:
                response_code = "ACCEPTED"
                freshness_label = payload.get("label")
                freshness_confidence = payload.get("confidence")
            else:
                error = payload.get("error") or {}
                response_code = error.get("code", f"HTTP_{response.status_code}")
                freshness_label = None
                freshness_confidence = None

            results.append(
                {
                    "name": case.get("name", img_path.name),
                    "image_path": str(img_path),
                    "expected_category": case["expected_category"],
                    "region_type": case["region_type"],
                    "group": case.get("group", "held_out"),
                    "http_status": response.status_code,
                    "response_code": response_code,
                    "model_b_ran": model_b_ran,
                    "freshness_label": freshness_label,
                    "freshness_confidence": freshness_confidence,
                }
            )

    return {
        "validator_checkpoint": str(validator_checkpoint) if validator_checkpoint else "active_default",
        "missing_files": missing_files,
        "results": results,
        "summary": {
            "held_out": _summarize_group([r for r in results if r["group"] != "regression"]),
            "regression": _summarize_group([r for r in results if r["group"] == "regression"]),
        },
    }


def _summarize_group(rows):
    non_fish = [r for r in rows if r["expected_category"] == "unsupported"]
    whole_fish = [r for r in rows if r["expected_category"] == "whole_tilapia"]
    usable = [r for r in rows if r["expected_category"] in {"eye", "gill"}]
    matching_usable = [r for r in usable if r["expected_category"] == r["region_type"]]

    return {
        "total": len(rows),
        "non_fish": {
            "total": len(non_fish),
            "false_accepts_model_b_ran": sum(1 for r in non_fish if r["model_b_ran"]),
            "rejected_before_model_b": sum(1 for r in non_fish if not r["model_b_ran"]),
        },
        "whole_tilapia": {
            "total": len(whole_fish),
            "close_up_prompts": sum(
                1 for r in whole_fish if r["response_code"] == "WHOLE_TILAPIA_CLOSE_UP_REQUIRED"
            ),
            "generic_rejections": sum(
                1
                for r in whole_fish
                if not r["model_b_ran"] and r["response_code"] != "WHOLE_TILAPIA_CLOSE_UP_REQUIRED"
            ),
            "incorrect_routing_model_b_ran": sum(1 for r in whole_fish if r["model_b_ran"]),
        },
        "usable_eye_gill": {
            "total": len(usable),
            "matching_mode_total": len(matching_usable),
            "accepted_by_model_a": sum(1 for r in matching_usable if r["model_b_ran"]),
            "freshness_returned_200": sum(
                1 for r in matching_usable if r["http_status"] == 200
            ),
            "freshness_uncertain_422": sum(
                1 for r in matching_usable if r["response_code"] == "FRESHNESS_UNCERTAIN"
            ),
        },
    }


def _build_default_challenge_cases():
    challenge_dir = BACKEND_DIR / "ml" / "challenge_images"
    cases = list(DEFAULT_REGRESSION_CASES)
    category_map = {
        "eye": "eye",
        "gill": "gill",
        "whole_fish": "whole_tilapia",
        "unrelated_objects": "unsupported",
        "other_fish_species": "unsupported",
    }
    for folder, expected_cat in category_map.items():
        folder_path = challenge_dir / folder
        if not folder_path.is_dir():
            continue
        for img in sorted(folder_path.iterdir()):
            if img.suffix.lower() not in {".png", ".jpg", ".jpeg"}:
                continue
            if img.name == "unrelated3.png":
                continue  # Already in DEFAULT_REGRESSION_CASES
            for mode in ("eye", "gill"):
                cases.append(
                    {
                        "name": f"{folder}/{img.name}_{mode}",
                        "image_path": str(img),
                        "expected_category": expected_cat,
                        "region_type": mode,
                        "group": "held_out",
                    }
                )
    return cases


def main():
    parser = argparse.ArgumentParser(description="Evaluate Model A upload endpoint.")
    parser.add_argument(
        "--validator-checkpoint",
        type=str,
        default=None,
        help="Explicit Model A checkpoint path to evaluate without replacing active checkpoint.",
    )
    parser.add_argument(
        "--cases",
        type=str,
        default=None,
        help="Optional JSON file containing list of {image_path, expected_category, region_type, group}.",
    )
    parser.add_argument(
        "--output",
        type=str,
        default=None,
        help="Optional JSON output path for full evaluation report.",
    )
    args = parser.parse_args()

    _setup_isolated_django()

    if args.cases:
        with open(args.cases, "r", encoding="utf-8") as f:
            cases = json.load(f)
        # Ensure known regression cases are included when running a custom list
        existing_keys = {(c["image_path"], c["region_type"]) for c in cases}
        for reg in DEFAULT_REGRESSION_CASES:
            if (reg["image_path"], reg["region_type"]) not in existing_keys:
                cases.append(reg)
    else:
        cases = _build_default_challenge_cases()

    report = evaluate_cases(cases, validator_checkpoint=args.validator_checkpoint)

    print(json.dumps(report["summary"], indent=2))
    if report["missing_files"]:
        print("\nMissing regression/case files:")
        for m in report["missing_files"]:
            print(f"  - {m['name']}: {m['image_path']}")

    if args.output:
        out_path = Path(args.output)
        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(report, indent=2), encoding="utf-8")
        print(f"\nFull report written to {out_path}")


if __name__ == "__main__":
    main()

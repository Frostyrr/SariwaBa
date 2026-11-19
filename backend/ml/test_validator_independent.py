
"""
SariwaBa Model A - Independent Image Challenge Test

Tests a previously trained experimental validator using
new images that were not part of the original dataset.

Features:
- Loads existing MobileNetV3-Small checkpoint
- Uses the same preprocessing as training
- Reports predictions and confidence scores
- Calculates per-category and overall accuracy
- Calculates Unsupported false-accept rate
- Checks exact SHA-256 matches against the original
  validator dataset and within the challenge collection
- Does not train, modify, or save a model

Run:
    python -m ml.test_validator_independent
"""

import csv
import hashlib
from collections import Counter
from pathlib import Path

import torch
import torch.nn as nn

from PIL import Image
from torchvision import models, transforms


BASE_DIR = Path(__file__).resolve().parent.parent

CHECKPOINT_PATH = (
    BASE_DIR
    / "ml"
    / "models"
    / "sariwaba_validator_experimental_best.pth"
)

CHALLENGE_DIR = BASE_DIR / "ml" / "challenge_images"

VALIDATOR_MANIFEST = (
    BASE_DIR
    / "datasets"
    / "metadata"
    / "validator_labels.csv"
)

CLASS_NAMES = ["eye", "gill", "unsupported"]

CATEGORY_EXPECTATIONS = {
    "eye": "eye",
    "gill": "gill",
    "whole_fish": "unsupported",
    "wrong_fish_regions": "unsupported",
    "other_fish_species": "unsupported",
    "unrelated_objects": "unsupported",
}

EXTENSIONS = {".jpg", ".jpeg", ".png"}
IMAGE_SIZE = 224

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

PREPROCESS = transforms.Compose([
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])


def sha256_file(path):
    digest = hashlib.sha256()

    with path.open("rb") as file:
        for chunk in iter(
            lambda: file.read(1024 * 1024),
            b"",
        ):
            digest.update(chunk)

    return digest.hexdigest()


def collect_challenge_images():
    images = []

    for category, expected_label in (
        CATEGORY_EXPECTATIONS.items()
    ):
        folder = CHALLENGE_DIR / category

        if not folder.is_dir():
            raise FileNotFoundError(
                f"Challenge folder missing: {folder}"
            )

        for path in sorted(folder.rglob("*")):
            if (
                path.is_file()
                and path.suffix.lower() in EXTENSIONS
            ):
                images.append({
                    "path": path,
                    "category": category,
                    "expected": expected_label,
                })

    return images


def load_original_hashes():
    if not VALIDATOR_MANIFEST.is_file():
        raise FileNotFoundError(
            VALIDATOR_MANIFEST
        )

    hashes = {}

    with VALIDATOR_MANIFEST.open(
        "r",
        newline="",
        encoding="utf-8-sig",
    ) as file:
        reader = csv.DictReader(file)

        if not reader.fieldnames or (
            "image_path" not in reader.fieldnames
        ):
            raise ValueError(
                "Validator manifest is missing image_path."
            )

        rows = list(reader)

    root = BASE_DIR.resolve()

    for row in rows:
        relative = Path(row["image_path"])

        if (
            relative.is_absolute()
            or ".." in relative.parts
        ):
            raise ValueError(
                f"Unsafe dataset path: {relative}"
            )

        absolute = (root / relative).resolve()

        if not absolute.is_relative_to(root):
            raise ValueError(
                f"Path outside project: {relative}"
            )

        if not absolute.is_file():
            raise FileNotFoundError(absolute)

        digest = sha256_file(absolute)

        # A hash may correspond to multiple original paths.
        hashes.setdefault(
            digest, []
        ).append(str(relative))

    return hashes


def check_independence(images):
    print()
    print("EXACT DUPLICATE SCREENING")
    print("-" * 60)

    original_hashes = load_original_hashes()

    seen_challenge_hashes = {}
    accepted = []
    excluded = []

    for item in images:
        digest = sha256_file(item["path"])

        reason = None

        if digest in original_hashes:
            reason = (
                "Exact duplicate of original dataset: "
                + original_hashes[digest][0]
            )

        elif digest in seen_challenge_hashes:
            reason = (
                "Exact duplicate within challenge: "
                + str(seen_challenge_hashes[digest])
            )

        if reason:
            excluded.append((item, reason))
        else:
            seen_challenge_hashes[digest] = item["path"]
            accepted.append(item)

    print("Original dataset hashes:", len(original_hashes))
    print("Challenge files discovered:", len(images))
    print("Exact duplicates excluded:", len(excluded))
    print("Eligible challenge files:", len(accepted))

    for item, reason in excluded:
        print()
        print("EXCLUDED:", item["path"].name)
        print("Reason:", reason)

    return accepted


def load_model():
    if not CHECKPOINT_PATH.is_file():
        raise FileNotFoundError(
            f"Checkpoint missing: {CHECKPOINT_PATH}"
        )

    # Load only the trusted checkpoint produced by
    # the project's own training script.
    checkpoint = torch.load(
        CHECKPOINT_PATH,
        map_location=DEVICE,
        weights_only=True,
    )

    expected_mapping = {
        "eye": 0,
        "gill": 1,
        "unsupported": 2,
    }

    if checkpoint.get("classes") != CLASS_NAMES:
        raise ValueError(
            "Checkpoint class list mismatch."
        )

    if checkpoint.get("class_to_idx") != (
        expected_mapping
    ):
        raise ValueError(
            "Checkpoint label mapping mismatch."
        )

    if checkpoint.get("image_size") != IMAGE_SIZE:
        raise ValueError(
            "Checkpoint image size mismatch."
        )

    if checkpoint.get("experimental") is not True:
        raise ValueError(
            "Expected experimental checkpoint."
        )

    model = models.mobilenet_v3_small(
        weights=None
    )

    in_features = (
        model.classifier[3].in_features
    )

    model.classifier[3] = nn.Linear(
        in_features,
        len(CLASS_NAMES),
    )

    model.load_state_dict(
        checkpoint["state_dict"],
        strict=True,
    )

    model.to(DEVICE)
    model.eval()

    return model, checkpoint


@torch.inference_mode()
def predict_image(model, image_path):
    with Image.open(image_path) as source:
        image = source.convert("RGB")

    tensor = PREPROCESS(image)
    tensor = tensor.unsqueeze(0).to(DEVICE)

    outputs = model(tensor)

    probabilities = torch.softmax(
        outputs,
        dim=1,
    )[0]

    predicted_index = int(
        probabilities.argmax().item()
    )

    predicted_label = CLASS_NAMES[
        predicted_index
    ]

    confidence = float(
        probabilities[predicted_index].item()
    )

    scores = {
        name: float(probabilities[index].item())
        for index, name in enumerate(CLASS_NAMES)
    }

    return predicted_label, confidence, scores


def main():
    print("=" * 60)
    print("SariwaBa Model A - Independent Challenge Test")
    print("=" * 60)

    images = collect_challenge_images()

    print("Challenge images discovered:", len(images))

    if not images:
        print()
        print("No challenge images found.")
        print(
            "Add new photographs to the challenge "
            "folders, then run this script again."
        )
        return

    eligible = check_independence(images)

    if not eligible:
        print()
        print(
            "No eligible images remain after "
            "exact duplicate screening."
        )
        return

    model, checkpoint = load_model()

    print()
    print("CHECKPOINT")
    print("-" * 60)

    print("Device:", DEVICE)
    print("Best epoch:", checkpoint["best_epoch"])
    print("Classes:", CLASS_NAMES)

    results = []
    unreadable = []

    print()
    print("INDIVIDUAL PREDICTIONS")
    print("-" * 60)

    for item in eligible:
        try:
            predicted, confidence, scores = (
                predict_image(
                    model,
                    item["path"],
                )
            )

        except Exception as exc:
            unreadable.append(
                (item["path"], str(exc))
            )
            print(
                "IMAGE ERROR:",
                item["path"].name,
                str(exc),
            )
            continue

        correct = (
            predicted == item["expected"]
        )

        results.append({
            **item,
            "predicted": predicted,
            "confidence": confidence,
            "correct": correct,
        })

        status = "PASS" if correct else "FAIL"

        print()
        print(
            f"[{status}] "
            f"{item['category']}/"
            f"{item['path'].name}"
        )

        print(
            f"  Expected: {item['expected']}"
        )

        print(
            f"  Predicted: {predicted}"
        )

        print(
            f"  Confidence: {confidence:.4f}"
        )

        print(
            "  Scores: "
            + ", ".join(
                f"{name}={score:.4f}"
                for name, score in scores.items()
            )
        )

    print()
    print("=" * 60)
    print("CHALLENGE TEST SUMMARY")
    print("=" * 60)

    total = len(results)

    if total == 0:
        print("No successfully evaluated images.")
        return

    correct = sum(
        item["correct"]
        for item in results
    )

    print("Images evaluated:", total)
    print("Correct predictions:", correct)
    print(
        "Overall accuracy:",
        f"{100 * correct / total:.2f}%",
    )

    print()
    print("CATEGORY BREAKDOWN")
    print("-" * 60)

    for category in CATEGORY_EXPECTATIONS:
        subset = [
            item for item in results
            if item["category"] == category
        ]

        if not subset:
            print(
                f"{category}: 0 images "
                "(NOT TESTED)"
            )
            continue

        successes = sum(
            item["correct"]
            for item in subset
        )

        print(
            f"{category}: "
            f"{successes}/{len(subset)} correct "
            f"({100 * successes / len(subset):.2f}%)"
        )

    unsupported = [
        item for item in results
        if item["expected"] == "unsupported"
    ]

    false_accepts = [
        item for item in unsupported
        if item["predicted"] != "unsupported"
    ]

    supported = [
        item for item in results
        if item["expected"] != "unsupported"
    ]

    false_rejects = [
        item for item in supported
        if item["predicted"] == "unsupported"
    ]

    print()
    print("VALIDATOR SAFETY METRICS")
    print("-" * 60)

    if unsupported:
        print(
            "Unsupported false-accept rate:",
            f"{100 * len(false_accepts) / len(unsupported):.2f}%",
            f"({len(false_accepts)}/{len(unsupported)})",
        )
    else:
        print(
            "Unsupported false-accept rate: "
            "NOT MEASURABLE"
        )

    if supported:
        print(
            "Supported false-reject rate:",
            f"{100 * len(false_rejects) / len(supported):.2f}%",
            f"({len(false_rejects)}/{len(supported)})",
        )
    else:
        print(
            "Supported false-reject rate: "
            "NOT MEASURABLE"
        )

    print()
    print("PREDICTION DISTRIBUTION")
    print("-" * 60)

    counts = Counter(
        item["predicted"]
        for item in results
    )

    for name in CLASS_NAMES:
        print(f"{name}: {counts[name]}")

    print()
    print("Unreadable challenge images:", len(unreadable))

    print()
    print("IMPORTANT:")
    print("- No model training was performed.")
    print("- Original datasets were not modified.")
    print("- Exact duplicates were excluded from testing.")
    print("- Near-duplicates may still exist.")
    print("- Challenge labels require manual verification.")
    print("- Confidence scores are not calibrated.")
    print("- These results are not final deployment approval.")
    print("- Model B remains unchanged.")


if __name__ == "__main__":
    main()

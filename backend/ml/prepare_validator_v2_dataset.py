
"""
SariwaBa Model A v2 - Positive Dataset Intake

Creates separate intake folders for new Tilapia
eye and gill photographs.

Generates and updates an intake CSV while preserving
previously entered source and review information.

Does not:
- Copy, move, rename, or delete original images
- Modify existing training/split manifests
- Modify model checkpoints
- Train a model or modify Django

Run from backend:
    python -m ml.prepare_validator_v2_dataset
"""

import csv
import hashlib
import os
import shutil
import uuid
from collections import Counter
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent
DATASETS_DIR = BASE_DIR / "datasets"
METADATA_DIR = DATASETS_DIR / "metadata"

CANDIDATE_DIR = (
    DATASETS_DIR / "validator_v2_candidates"
)

INTAKE_CSV = (
    METADATA_DIR / "validator_v2_intake.csv"
)

VALIDATOR_CSV = (
    METADATA_DIR / "validator_labels.csv"
)

CHALLENGE_DIR = (
    BASE_DIR / "ml" / "challenge_images"
)

CATEGORIES = ("eye", "gill")
EXTENSIONS = {".jpg", ".jpeg", ".png"}

COLUMNS = [
    "image_path",
    "anatomical_label",
    "source_id",
    "source_description",
    "verified_tilapia",
    "review_status",
    "notes",
]


def digest(path):
    hasher = hashlib.sha256()

    with path.open("rb") as file:
        for chunk in iter(
            lambda: file.read(1024 * 1024),
            b"",
        ):
            hasher.update(chunk)

    return hasher.hexdigest()


def read_existing_intake():
    if not INTAKE_CSV.exists():
        return {}

    with INTAKE_CSV.open(
        "r",
        newline="",
        encoding="utf-8-sig",
    ) as file:
        reader = csv.DictReader(file)

        if not reader.fieldnames:
            raise ValueError("Intake CSV has no header.")

        if not set(COLUMNS).issubset(reader.fieldnames):
            raise ValueError(
                "Intake CSV columns are incomplete."
            )

        result = {}

        for row in reader:
            path = row["image_path"].strip()

            if not path or path in result:
                raise ValueError(
                    f"Invalid or duplicate intake path: {path}"
                )

            result[path] = {
                key: row.get(key, "")
                for key in COLUMNS
            }

        return result


def collect_candidates():
    result = {}
    root = BASE_DIR.resolve()

    for category in CATEGORIES:
        directory = CANDIDATE_DIR / category

        for path in sorted(directory.rglob("*")):
            if (
                not path.is_file()
                or path.suffix.lower() not in EXTENSIONS
            ):
                continue

            resolved = path.resolve()

            if not resolved.is_relative_to(root):
                raise ValueError(
                    f"Image outside backend: {path}"
                )

            relative = path.relative_to(
                BASE_DIR
            ).as_posix()

            if relative in result:
                raise ValueError(
                    f"Duplicate candidate path: {relative}"
                )

            result[relative] = category

    return result


def original_hashes():
    if not VALIDATOR_CSV.is_file():
        raise FileNotFoundError(VALIDATOR_CSV)

    hashes = set()

    with VALIDATOR_CSV.open(
        "r",
        newline="",
        encoding="utf-8-sig",
    ) as file:
        reader = csv.DictReader(file)

        if not reader.fieldnames or (
            "image_path" not in reader.fieldnames
        ):
            raise ValueError(
                "Invalid original validator manifest."
            )

        for row in reader:
            relative = Path(row["image_path"])

            if (
                relative.is_absolute()
                or ".." in relative.parts
            ):
                raise ValueError(
                    f"Unsafe original image path: {relative}"
                )

            path = (BASE_DIR / relative).resolve()

            if not path.is_relative_to(
                BASE_DIR.resolve()
            ):
                raise ValueError(
                    f"Original image outside backend: {path}"
                )

            if not path.is_file():
                raise FileNotFoundError(path)

            hashes.add(digest(path))

    return hashes


def challenge_hashes():
    hashes = set()

    if not CHALLENGE_DIR.exists():
        return hashes

    for path in CHALLENGE_DIR.rglob("*"):
        if (
            path.is_file()
            and path.suffix.lower() in EXTENSIONS
        ):
            hashes.add(digest(path))

    return hashes


def write_intake(rows, previous_exists):
    METADATA_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    ordered = [
        rows[key]
        for key in sorted(rows)
    ]

    if not previous_exists:
        with INTAKE_CSV.open(
            "x",
            newline="",
            encoding="utf-8",
        ) as file:
            writer = csv.DictWriter(
                file,
                fieldnames=COLUMNS,
            )

            writer.writeheader()
            writer.writerows(ordered)

        return "created"

    # No rewrite if nothing changed.
    old_rows = read_existing_intake()

    if rows == old_rows:
        return "unchanged"

    update_id = uuid.uuid4().hex[:12]

    backup = INTAKE_CSV.with_name(
        INTAKE_CSV.name + ".backup_" + update_id
    )

    temporary = INTAKE_CSV.with_name(
        INTAKE_CSV.name + ".tmp_" + update_id
    )

    shutil.copy2(INTAKE_CSV, backup)

    try:
        with temporary.open(
            "x",
            newline="",
            encoding="utf-8",
        ) as file:
            writer = csv.DictWriter(
                file,
                fieldnames=COLUMNS,
            )

            writer.writeheader()
            writer.writerows(ordered)

        os.replace(temporary, INTAKE_CSV)

    finally:
        temporary.unlink(missing_ok=True)

    print("Previous intake backup:", backup)

    return "updated"


def main():
    print("=" * 60)
    print("SariwaBa Model A v2 - Dataset Intake")
    print("=" * 60)

    for category in CATEGORIES:
        directory = CANDIDATE_DIR / category

        directory.mkdir(
            parents=True,
            exist_ok=True,
        )

    candidates = collect_candidates()

    existing = read_existing_intake()

    # Preserve records and manual source information.
    # Missing previously registered files are errors.
    missing = set(existing) - set(candidates)

    if missing:
        raise ValueError(
            "Previously registered candidate images "
            "are now missing:\n"
            + "\n".join(sorted(missing)[:20])
        )

    records = dict(existing)
    new_count = 0

    for relative, category in candidates.items():
        if relative in records:
            if (
                records[relative]["anatomical_label"]
                != category
            ):
                raise ValueError(
                    f"Label conflict: {relative}"
                )

            continue

        records[relative] = {
            "image_path": relative,
            "anatomical_label": category,
            "source_id": "",
            "source_description": "",
            "verified_tilapia": "",
            "review_status": "pending",
            "notes": "",
        }

        new_count += 1

    # Screen all candidate files, not just new entries.
    seen_hashes = {}
    reference_hashes = None
    test_hashes = None

    if candidates:
        reference_hashes = original_hashes()
        test_hashes = challenge_hashes()

    duplicate_warnings = []
    reference_warnings = []

    for relative in sorted(candidates):
        image_path = BASE_DIR / relative
        image_hash = digest(image_path)

        if image_hash in seen_hashes:
            duplicate_warnings.append(
                (relative, seen_hashes[image_hash])
            )

        else:
            seen_hashes[image_hash] = relative

        if image_hash in reference_hashes:
            reference_warnings.append(
                (relative, "existing validator dataset")
            )

        if image_hash in test_hashes:
            reference_warnings.append(
                (relative, "independent challenge set")
            )

    status = write_intake(
        records,
        INTAKE_CSV.exists(),
    )

    counts = Counter(candidates.values())

    reviewed = Counter(
        row["review_status"].strip().lower()
        for row in records.values()
    )

    print()
    print("DATASET INTAKE SUMMARY")
    print("-" * 60)

    print("Eye candidates:", counts["eye"])
    print("Gill candidates:", counts["gill"])
    print("Total candidates:", len(candidates))
    print("New records:", new_count)
    print("Intake CSV:", status)
    print("Approved records:", reviewed["approved"])
    print("Pending records:", reviewed["pending"])

    print()
    print("DUPLICATE SCREENING")
    print("-" * 60)

    print(
        "Exact duplicates within candidates:",
        len(duplicate_warnings),
    )

    print(
        "Exact matches to reference images:",
        len(reference_warnings),
    )

    for image_path, matched in (
        duplicate_warnings + reference_warnings
    ):
        print(f"  REVIEW: {image_path}")
        print(f"    Matches: {matched}")

    print()
    print("IMAGE FOLDERS")
    print("-" * 60)

    for category in CATEGORIES:
        print(CANDIDATE_DIR / category)

    print()
    print("INTAKE MANIFEST")
    print(INTAKE_CSV)

    print()
    print("IMPORTANT:")
    print("- Original datasets remain unchanged.")
    print("- All previous source information was preserved.")
    print("- Source IDs must be entered manually.")
    print("- Tilapia identity requires verification.")
    print("- Review status must be manually approved.")
    print("- Exact duplicates must not enter training.")
    print("- Near-duplicates still require review.")
    print("- No v2 training split was created.")
    print("- No model training was performed.")
    print("- Model B remains untouched.")


if __name__ == "__main__":
    main()

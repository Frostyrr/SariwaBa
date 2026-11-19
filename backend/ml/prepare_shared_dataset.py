
"""
SariwaBa - Shared Dataset Metadata Updater

Adds Unsupported image references to the existing shared
dataset manifests.

Does NOT:
- Copy, move, rename, or delete images
- Modify freshness_labels.csv
- Change existing labels or splits
- Assign specimen IDs
- Train or overwrite any model

Run from the backend directory:
    python ml/prepare_shared_dataset.py
"""

import csv
import os
import shutil
import uuid

from collections import Counter
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent

DATASETS_DIR = BASE_DIR / "datasets"
UNSUPPORTED_DIR = DATASETS_DIR / "unsupported"
METADATA_DIR = DATASETS_DIR / "metadata"

FRESHNESS_CSV = METADATA_DIR / "freshness_labels.csv"
VALIDATOR_CSV = METADATA_DIR / "validator_labels.csv"
SPLITS_CSV = METADATA_DIR / "splits.csv"

VALID_EXTENSIONS = {".jpg", ".jpeg", ".png"}

VALIDATOR_COLUMNS = [
    "image_path",
    "anatomical_label",
    "freshness_label",
    "negative_category",
    "group_key",
    "specimen_id",
]

SPLIT_COLUMNS = [
    "image_path",
    "group_key",
    "group_basis",
    "specimen_id",
    "split",
    "split_status",
]


def read_manifest(path):
    if not path.is_file():
        raise FileNotFoundError(
            f"Required manifest not found: {path}"
        )

    with path.open(
        "r",
        newline="",
        encoding="utf-8-sig",
    ) as file:
        reader = csv.DictReader(file)

        if not reader.fieldnames:
            raise ValueError(
                f"Invalid CSV header: {path}"
            )

        return reader.fieldnames, list(reader)


def validate_columns(actual, required, path):
    missing = set(required) - set(actual)

    if missing:
        raise ValueError(
            f"Missing columns in {path}: "
            f"{sorted(missing)}"
        )


def build_path_lookup(rows, name):
    lookup = {}

    for row in rows:
        image_path = row["image_path"]

        if not image_path:
            raise ValueError(
                f"Empty image path in {name}"
            )

        if image_path in lookup:
            raise ValueError(
                f"Duplicate path in {name}: "
                f"{image_path}"
            )

        lookup[image_path] = row

    return lookup


def scan_unsupported_images():
    if not UNSUPPORTED_DIR.is_dir():
        raise FileNotFoundError(
            f"Unsupported directory missing: "
            f"{UNSUPPORTED_DIR}"
        )

    images = sorted(
        (
            path
            for path in UNSUPPORTED_DIR.rglob("*")
            if path.is_file()
            and path.suffix.lower()
            in VALID_EXTENSIONS
        ),
        key=lambda path: path.as_posix().lower(),
    )

    records = []

    for path in images:
        relative = path.relative_to(
            UNSUPPORTED_DIR
        )

        if len(relative.parts) < 2:
            raise ValueError(
                "Unsupported images must be inside "
                f"a category folder: {path}"
            )

        category = relative.parts[0]

        image_path = path.relative_to(
            BASE_DIR
        ).as_posix()

        # This is a provisional group only.
        # It is NOT a verified specimen/source ID.
        group_key = (
            f"Unsupported::"
            f"{relative.parent.as_posix()}"
        )

        records.append({
            "image_path": image_path,
            "category": category,
            "group_key": group_key,
        })

    return records


def write_temporary_csv(
    destination,
    columns,
    rows,
    temporary_path,
):
    with temporary_path.open(
        "x",
        newline="",
        encoding="utf-8",
    ) as file:
        writer = csv.DictWriter(
            file,
            fieldnames=columns,
        )

        writer.writeheader()
        writer.writerows(rows)


def main():
    print("=" * 60)
    print("SariwaBa Shared Dataset Metadata Update")
    print("=" * 60)

    # Read existing manifests.
    freshness_columns, freshness_rows = (
        read_manifest(FRESHNESS_CSV)
    )

    validator_columns, validator_rows = (
        read_manifest(VALIDATOR_CSV)
    )

    split_columns, split_rows = (
        read_manifest(SPLITS_CSV)
    )

    validate_columns(
        freshness_columns,
        ["image_path", "freshness_label"],
        FRESHNESS_CSV,
    )

    validate_columns(
        validator_columns,
        VALIDATOR_COLUMNS,
        VALIDATOR_CSV,
    )

    validate_columns(
        split_columns,
        SPLIT_COLUMNS,
        SPLITS_CSV,
    )

    freshness_lookup = build_path_lookup(
        freshness_rows,
        "freshness_labels.csv",
    )

    validator_lookup = build_path_lookup(
        validator_rows,
        "validator_labels.csv",
    )

    split_lookup = build_path_lookup(
        split_rows,
        "splits.csv",
    )

    # Refuse to proceed if the existing metadata
    # is already inconsistent.
    if set(validator_lookup) != set(split_lookup):
        raise ValueError(
            "Validator and split manifests contain "
            "different image paths. "
            "Resolve the mismatch before updating."
        )

    # Ensure existing freshness samples are represented
    # in the validator manifest.
    if not set(freshness_lookup).issubset(
        set(validator_lookup)
    ):
        raise ValueError(
            "Some existing freshness images are missing "
            "from validator_labels.csv."
        )

    unsupported_images = scan_unsupported_images()

    print(
        f"Unsupported images discovered: "
        f"{len(unsupported_images)}"
    )

    category_counts = Counter(
        item["category"]
        for item in unsupported_images
    )

    for category, count in sorted(
        category_counts.items()
    ):
        print(f"  {category}: {count}")

    print()

    new_validator_rows = []
    new_split_rows = []

    for item in unsupported_images:
        image_path = item["image_path"]

        if image_path in freshness_lookup:
            raise ValueError(
                "Unsupported image is already listed "
                "as a freshness sample: "
                f"{image_path}"
            )

        if image_path in validator_lookup:
            existing = validator_lookup[image_path]

            if (
                existing["anatomical_label"]
                != "unsupported"
            ):
                raise ValueError(
                    "Existing image label conflict: "
                    f"{image_path}"
                )

            # Already registered. Do not duplicate.
            continue

        new_validator_rows.append({
            "image_path": image_path,
            "anatomical_label": "unsupported",
            "freshness_label": "",
            "negative_category": item["category"],
            "group_key": item["group_key"],
            "specimen_id": "",
        })

        new_split_rows.append({
            "image_path": image_path,
            "group_key": item["group_key"],
            "group_basis": "unsupported_source_unverified",
            "specimen_id": "",
            "split": "",
            "split_status": "unassigned",
        })

    print(
        f"Already registered: "
        f"{len(unsupported_images) - len(new_validator_rows)}"
    )

    print(
        f"New unsupported records: "
        f"{len(new_validator_rows)}"
    )

    if not new_validator_rows:
        print("\nNo new images to register.")
        print("Existing manifests were not modified.")
        return

    updated_validator = (
        validator_rows + new_validator_rows
    )

    updated_splits = (
        split_rows + new_split_rows
    )

    # Create unique backups and temporary files.
    # Keep backups for manual recovery.
    update_id = uuid.uuid4().hex[:12]

    updates = [
        (
            VALIDATOR_CSV,
            validator_columns,
            updated_validator,
        ),
        (
            SPLITS_CSV,
            split_columns,
            updated_splits,
        ),
    ]

    backups = []
    temporary_files = []
    replaced = []

    try:
        # Prepare both backups and full updated CSVs
        # before modifying either original file.
        for destination, columns, rows in updates:
            backup = destination.with_name(
                destination.name
                + f".backup_{update_id}"
            )

            temporary = destination.with_name(
                destination.name
                + f".tmp_{update_id}"
            )

            shutil.copy2(destination, backup)
            backups.append((destination, backup))

            write_temporary_csv(
                destination,
                columns,
                rows,
                temporary,
            )

            temporary_files.append(temporary)

        # Replace originals only after preparation.
        for index, (destination, _, _) in enumerate(
            updates
        ):
            os.replace(
                temporary_files[index],
                destination,
            )
            replaced.append(destination)

    except Exception:
        # Restore any original manifest already replaced.
        for destination in replaced:
            for original, backup in backups:
                if original == destination:
                    shutil.copy2(backup, destination)
                    break

        raise

    finally:
        for temporary in temporary_files:
            temporary.unlink(missing_ok=True)

    print()
    print("UPDATED METADATA")
    print("-" * 60)

    print(
        f"Freshness records: "
        f"{len(freshness_rows)} (unchanged)"
    )

    print(
        f"Validator records: "
        f"{len(updated_validator)}"
    )

    print(
        f"Split records: "
        f"{len(updated_splits)}"
    )

    print()
    print("Backups created:")

    for _, backup in backups:
        print(backup)

    print()
    print("IMPORTANT:")
    print("- Original images were not modified.")
    print("- Freshness manifest was not modified.")
    print("- Existing split assignments were preserved.")
    print("- New images have unassigned splits.")
    print("- Specimen/source IDs still require verification.")
    print("- No ML training was performed.")
    print("- Model B checkpoint remains unchanged.")

    print()
    print("Metadata update completed successfully.")


if __name__ == "__main__":
    main()


"""
SariwaBa - Validator Exact Duplicate Exclusion Generator

Purpose:
    Identify exact duplicate images within the Unsupported
    dataset and generate a CSV identifying which duplicate
    records should be excluded from Model A training.

This script:
    - Reads validator_labels.csv
    - Checks SHA-256 hashes of Unsupported images
    - Creates validator_exclusions.csv
    - Preserves every existing image
    - Does not modify existing dataset manifests
    - Does not modify or train either ML model

Run:
    python ml/create_validator_exclusions.py
"""

import csv
import hashlib

from collections import defaultdict
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent
DATASETS_DIR = BASE_DIR / "datasets"
METADATA_DIR = DATASETS_DIR / "metadata"

VALIDATOR_CSV = METADATA_DIR / "validator_labels.csv"

EXCLUSIONS_CSV = (
    METADATA_DIR / "validator_exclusions.csv"
)

UNSUPPORTED_DIR = (
    DATASETS_DIR / "unsupported"
)


def read_validator_manifest():
    if not VALIDATOR_CSV.is_file():
        raise FileNotFoundError(
            f"Validator manifest missing: {VALIDATOR_CSV}"
        )

    with VALIDATOR_CSV.open(
        "r",
        newline="",
        encoding="utf-8-sig",
    ) as file:

        reader = csv.DictReader(file)

        required = {
            "image_path",
            "anatomical_label",
        }

        if not reader.fieldnames:
            raise ValueError(
                "Validator manifest has no CSV header."
            )

        missing = required - set(reader.fieldnames)

        if missing:
            raise ValueError(
                f"Missing columns: {sorted(missing)}"
            )

        return list(reader)


def calculate_sha256(image_path):
    hasher = hashlib.sha256()

    with image_path.open("rb") as file:
        for chunk in iter(
            lambda: file.read(1024 * 1024),
            b"",
        ):
            hasher.update(chunk)

    return hasher.hexdigest()


def get_unsupported_records(records):
    unsupported = []

    root = BASE_DIR.resolve()
    unsupported_root = UNSUPPORTED_DIR.resolve()

    for record in records:
        if record["anatomical_label"] != "unsupported":
            continue

        relative_path = Path(record["image_path"])

        if (
            relative_path.is_absolute()
            or ".." in relative_path.parts
        ):
            raise ValueError(
                f"Unsafe image path: {relative_path}"
            )

        absolute_path = (
            BASE_DIR / relative_path
        ).resolve()

        if not absolute_path.is_relative_to(root):
            raise ValueError(
                f"Image outside project: {relative_path}"
            )

        if not absolute_path.is_relative_to(
            unsupported_root
        ):
            raise ValueError(
                "Unsupported record outside its directory: "
                f"{relative_path}"
            )

        if not absolute_path.is_file():
            raise FileNotFoundError(
                f"Missing image: {absolute_path}"
            )

        unsupported.append({
            "image_path": relative_path.as_posix(),
            "absolute_path": absolute_path,
        })

    return unsupported


def main():
    print("=" * 60)
    print("SariwaBa Model A - Exact Duplicate Audit")
    print("=" * 60)

    if EXCLUSIONS_CSV.exists():
        raise FileExistsError(
            "Exclusion manifest already exists. "
            "Nothing overwritten:\n"
            f"{EXCLUSIONS_CSV}"
        )

    records = read_validator_manifest()

    unsupported = get_unsupported_records(records)

    print(
        f"Unsupported records found: {len(unsupported)}"
    )

    if not unsupported:
        raise RuntimeError(
            "No Unsupported records were found."
        )

    hashes = defaultdict(list)
    seen_paths = set()

    for record in unsupported:
        image_path = record["image_path"]

        if image_path in seen_paths:
            raise ValueError(
                f"Duplicate manifest path: {image_path}"
            )

        seen_paths.add(image_path)

        image_hash = calculate_sha256(
            record["absolute_path"]
        )

        hashes[image_hash].append(
            image_path
        )

    exclusions = []
    duplicate_groups = 0

    for image_hash, paths in sorted(
        hashes.items()
    ):
        if len(paths) < 2:
            continue

        duplicate_groups += 1

        # Deterministic choice of original:
        # keep the alphabetically first path.
        paths = sorted(paths)

        original = paths[0]

        print()
        print("Duplicate group:")
        print(f"  KEEP: {original}")

        for duplicate in paths[1:]:
            print(f"  EXCLUDE: {duplicate}")

            exclusions.append({
                "image_path": duplicate,
                "duplicate_of": original,
                "reason": "exact_sha256_duplicate",
                "sha256": image_hash,
            })

    exclusions.sort(
        key=lambda row: row["image_path"]
    )

    METADATA_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    fieldnames = [
        "image_path",
        "duplicate_of",
        "reason",
        "sha256",
    ]

    # Exclusive creation prevents overwriting an
    # existing exclusion manifest.
    with EXCLUSIONS_CSV.open(
        "x",
        newline="",
        encoding="utf-8",
    ) as file:
        writer = csv.DictWriter(
            file,
            fieldnames=fieldnames,
        )

        writer.writeheader()
        writer.writerows(exclusions)

    unique_count = (
        len(unsupported) - len(exclusions)
    )

    print()
    print("=" * 60)
    print("AUDIT SUMMARY")
    print("=" * 60)

    print(
        f"Total Unsupported images: {len(unsupported)}"
    )
    print(
        f"Exact duplicate groups: {duplicate_groups}"
    )
    print(
        f"Excluded duplicate records: {len(exclusions)}"
    )
    print(
        f"Unique Unsupported images: {unique_count}"
    )

    print()
    print("Exclusion manifest created:")
    print(EXCLUSIONS_CSV)

    print()
    print("IMPORTANT:")
    print("- Original images remain unchanged.")
    print("- Original dataset manifests remain unchanged.")
    print("- Exclusions apply only when a loader uses this CSV.")
    print("- Near-duplicates have not been evaluated.")
    print("- No model training was performed.")
    print("- Model B checkpoint was not modified.")


if __name__ == "__main__":
    main()

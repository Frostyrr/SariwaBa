
"""
SariwaBa Model A - Provisional Source Group Review

Creates a review-only CSV of the Unsupported images,
using filename prefixes as conservative grouping clues.

Important:
- A filename prefix is NOT a verified source identity.
- Images sharing a prefix are grouped together provisionally.
- No training/validation/test splits are assigned.
- Original images and existing metadata stay unchanged.
- Model B is never modified.

Run from backend:
    python -m ml.prepare_validator_source_groups
"""

import csv
import re
from collections import Counter, defaultdict
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent

METADATA_DIR = (
    BASE_DIR / "datasets" / "metadata"
)

VALIDATOR_CSV = (
    METADATA_DIR / "validator_labels.csv"
)

EXCLUSIONS_CSV = (
    METADATA_DIR / "validator_exclusions.csv"
)

OUTPUT_CSV = (
    METADATA_DIR / "validator_source_groups.csv"
)

ALLOWED_EXTENSIONS = {".jpg", ".jpeg", ".png"}

OUTPUT_COLUMNS = [
    "image_path",
    "anatomical_label",
    "negative_category",
    "filename_prefix",
    "proposed_group_key",
    "group_basis",
    "category_overlap",
    "verified_source_id",
    "review_status",
]


def read_csv(path, required_columns):
    if not path.is_file():
        raise FileNotFoundError(
            f"Missing file: {path}"
        )

    with path.open(
        "r",
        encoding="utf-8-sig",
        newline="",
    ) as file:
        reader = csv.DictReader(file)

        if not reader.fieldnames:
            raise ValueError(
                f"Missing CSV header: {path}"
            )

        missing = (
            set(required_columns)
            - set(reader.fieldnames)
        )

        if missing:
            raise ValueError(
                f"Missing columns in {path.name}: "
                f"{sorted(missing)}"
            )

        return list(reader)


def validate_unique_paths(rows, filename):
    seen = set()

    for row in rows:
        image_path = row["image_path"].strip()

        if not image_path:
            raise ValueError(
                f"Empty image path in {filename}"
            )

        if image_path in seen:
            raise ValueError(
                f"Duplicate image path in {filename}: "
                f"{image_path}"
            )

        seen.add(image_path)


def get_filename_prefix(image_path):
    stem = Path(image_path).stem.lower()

    # Remove trailing image numbers.
    prefix = re.sub(r"\d+$", "", stem)

    prefix = prefix.strip("_- ")

    if not prefix:
        raise ValueError(
            "Cannot determine filename prefix: "
            f"{image_path}"
        )

    return prefix


def validate_image_path(image_path):
    relative = Path(image_path)

    if (
        relative.is_absolute()
        or ".." in relative.parts
    ):
        raise ValueError(
            f"Unsafe image path: {image_path}"
        )

    absolute = (
        BASE_DIR / relative
    ).resolve()

    if not absolute.is_relative_to(
        BASE_DIR.resolve()
    ):
        raise ValueError(
            f"Path outside backend: {image_path}"
        )

    if not absolute.is_file():
        raise FileNotFoundError(
            f"Missing image: {absolute}"
        )

    if absolute.suffix.lower() not in (
        ALLOWED_EXTENSIONS
    ):
        raise ValueError(
            f"Unsupported extension: {absolute}"
        )

    return absolute


def main():
    print("=" * 60)
    print("SariwaBa Model A - Source Group Review")
    print("=" * 60)

    if OUTPUT_CSV.exists():
        raise FileExistsError(
            "Source-group review already exists. "
            "No files overwritten:\n"
            f"{OUTPUT_CSV}"
        )

    validator_rows = read_csv(
        VALIDATOR_CSV,
        [
            "image_path",
            "anatomical_label",
            "negative_category",
        ],
    )

    exclusion_rows = read_csv(
        EXCLUSIONS_CSV,
        ["image_path"],
    )

    validate_unique_paths(
        validator_rows,
        "validator_labels.csv",
    )

    validate_unique_paths(
        exclusion_rows,
        "validator_exclusions.csv",
    )

    validator_paths = {
        row["image_path"].strip()
        for row in validator_rows
    }

    excluded_paths = {
        row["image_path"].strip()
        for row in exclusion_rows
    }

    if not excluded_paths.issubset(
        validator_paths
    ):
        raise ValueError(
            "Exclusions contain unknown image paths."
        )

    retained = []

    for row in validator_rows:
        if (
            row["anatomical_label"].strip()
            != "unsupported"
        ):
            continue

        image_path = row["image_path"].strip()

        if image_path in excluded_paths:
            continue

        validate_image_path(image_path)

        parts = Path(image_path).parts

        if (
            len(parts) < 4
            or parts[0] != "datasets"
            or parts[1] != "unsupported"
        ):
            raise ValueError(
                "Unexpected Unsupported path: "
                f"{image_path}"
            )

        category = parts[2]

        if (
            row["negative_category"].strip()
            != category
        ):
            raise ValueError(
                "Category mismatch: "
                f"{image_path}"
            )

        prefix = get_filename_prefix(
            image_path
        )

        retained.append({
            "image_path": image_path,
            "anatomical_label": "unsupported",
            "negative_category": category,
            "filename_prefix": prefix,
        })

    if not retained:
        raise ValueError(
            "No retained Unsupported images found."
        )

    # Identify prefixes that occur across categories.
    prefix_categories = defaultdict(set)

    for row in retained:
        prefix_categories[
            row["filename_prefix"]
        ].add(row["negative_category"])

    output_rows = []

    for row in retained:
        prefix = row["filename_prefix"]

        # Conservative proposal:
        # same prefix across categories -> same group.
        # This is NOT a verified specimen/source ID.
        proposed_group = (
            f"unsupported_prefix::{prefix}"
        )

        categories = prefix_categories[prefix]

        output_rows.append({
            **row,
            "proposed_group_key": proposed_group,
            "group_basis": (
                "filename_prefix_unverified"
            ),
            "category_overlap": (
                "yes" if len(categories) > 1
                else "no"
            ),
            "verified_source_id": "",
            "review_status": "needs_review",
        })

    output_rows.sort(
        key=lambda item: item["image_path"]
    )

    group_counts = Counter(
        row["proposed_group_key"]
        for row in output_rows
    )

    group_category_counts = Counter(
        (
            row["proposed_group_key"],
            row["negative_category"],
        )
        for row in output_rows
    )

    group_paths = defaultdict(list)

    for row in output_rows:
        group_paths[
            row["proposed_group_key"]
        ].append(row["image_path"])

    # Confirm every Rohu record stays in one group.
    rohu_groups = {
        row["proposed_group_key"]
        for row in output_rows
        if row["filename_prefix"] == "rohu"
    }

    if len(rohu_groups) > 1:
        raise ValueError(
            "Rohu photographs have multiple "
            "proposed source groups."
        )

    # Create review CSV without overwriting
    # existing source-group work.
    with OUTPUT_CSV.open(
        "x",
        newline="",
        encoding="utf-8",
    ) as file:
        writer = csv.DictWriter(
            file,
            fieldnames=OUTPUT_COLUMNS,
        )

        writer.writeheader()
        writer.writerows(output_rows)

    print()
    print("DATASET SUMMARY")
    print("-" * 60)

    print(
        f"Retained Unsupported images: "
        f"{len(output_rows)}"
    )

    print(
        f"Excluded exact duplicates: "
        f"{len(excluded_paths)}"
    )

    print(
        f"Provisional prefix groups: "
        f"{len(group_counts)}"
    )

    print()
    print("PROPOSED GROUPS")
    print("-" * 60)

    for group in sorted(group_counts):
        print()
        print(
            f"{group}: {group_counts[group]} images"
        )

        categories = sorted({
            row["negative_category"]
            for row in output_rows
            if row["proposed_group_key"] == group
        })

        for category in categories:
            count = group_category_counts[
                (group, category)
            ]

            print(f"  {category}: {count}")

        if len(categories) > 1:
            print(
                "  WARNING: Prefix appears "
                "across multiple categories."
            )

    print()
    print("ROHU GROUP CHECK")
    print("-" * 60)

    if rohu_groups:
        rohu_group = next(iter(rohu_groups))

        print("Group:", rohu_group)
        print(
            "Images:",
            len(group_paths[rohu_group]),
        )
    else:
        print("No Rohu images found.")

    print()
    print("REVIEW OUTPUT")
    print("-" * 60)
    print(OUTPUT_CSV)

    print()
    print("IMPORTANT:")
    print("- Groups are provisional only.")
    print("- Prefixes do not prove source identity.")
    print("- Cross-category groups need review.")
    print("- No train/val/test split was assigned.")
    print("- Existing metadata files were not changed.")
    print("- Original images were not changed.")
    print("- Model B remains untouched.")
    print("- Model A training has not started.")


if __name__ == "__main__":
    main()

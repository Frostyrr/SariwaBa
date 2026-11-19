
"""
SariwaBa Model A - Experimental Dataset Split Preparation

Creates:
    datasets/metadata/validator_experimental_splits.csv

Uses:
    validator_split_plan.csv
    validator_source_groups.csv
    validator_exclusions.csv

Does not modify original images, existing metadata manifests,
or the Model B freshness checkpoint.

Run from backend:
    python -m ml.prepare_validator_experimental_splits

WARNING:
These splits are for exploratory Model A training only.
Filename-based groupings are not verified specimen/source IDs.
"""

import csv
from collections import Counter, defaultdict
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent
METADATA_DIR = BASE_DIR / "datasets" / "metadata"

PLAN_CSV = METADATA_DIR / "validator_split_plan.csv"
SOURCES_CSV = METADATA_DIR / "validator_source_groups.csv"
EXCLUSIONS_CSV = METADATA_DIR / "validator_exclusions.csv"

OUTPUT_CSV = (
    METADATA_DIR / "validator_experimental_splits.csv"
)

CLASSES = ("eye", "gill", "unsupported")
PARTITIONS = ("train", "val", "test")

# Conservative experimental group assignments.
# These groups were identified from filename prefixes,
# not verified specimen identities.
UNSUPPORTED_ASSIGNMENTS = {
    "unsupported_prefix::bangus": "train",
    "unsupported_prefix::catfish": "train",
    "unsupported_prefix::full_body": "train",
    "unsupported_prefix::rohu": "train",
    "unsupported_prefix::horsemackerel": "val",
    "unsupported_prefix::trout": "test",
}

OUTPUT_COLUMNS = [
    "image_path",
    "anatomical_label",
    "negative_category",
    "group_key",
    "group_basis",
    "specimen_id",
    "split",
    "split_status",
]


def read_csv(path, required):
    if not path.is_file():
        raise FileNotFoundError(
            f"Required file missing: {path}"
        )

    with path.open(
        "r",
        newline="",
        encoding="utf-8-sig",
    ) as file:
        reader = csv.DictReader(file)

        if not reader.fieldnames:
            raise ValueError(
                f"Missing CSV header: {path}"
            )

        missing = set(required) - set(reader.fieldnames)

        if missing:
            raise ValueError(
                f"{path.name} missing: {sorted(missing)}"
            )

        return list(reader)


def index_rows(rows, name):
    result = {}

    for row in rows:
        path = row["image_path"].strip().replace("\\", "/")

        if not path:
            raise ValueError(
                f"Empty path in {name}"
            )

        if path in result:
            raise ValueError(
                f"Duplicate path in {name}: {path}"
            )

        result[path] = row

    return result


def validate_image_path(image_path):
    relative = Path(image_path)

    if relative.is_absolute() or ".." in relative.parts:
        raise ValueError(
            f"Unsafe image path: {image_path}"
        )

    absolute = (BASE_DIR / relative).resolve()

    if not absolute.is_relative_to(BASE_DIR.resolve()):
        raise ValueError(
            f"Path outside backend: {image_path}"
        )

    if not absolute.is_file():
        raise FileNotFoundError(
            f"Missing image: {absolute}"
        )


def main():
    print("=" * 60)
    print("SariwaBa Model A - Experimental Split Preparation")
    print("=" * 60)

    if OUTPUT_CSV.exists():
        raise FileExistsError(
            "Experimental split file already exists. "
            "Nothing overwritten:\n"
            f"{OUTPUT_CSV}"
        )

    plan_rows = read_csv(
        PLAN_CSV,
        [
            "image_path",
            "anatomical_label",
            "group_key",
            "split",
        ],
    )

    source_rows = read_csv(
        SOURCES_CSV,
        [
            "image_path",
            "anatomical_label",
            "negative_category",
            "proposed_group_key",
            "group_basis",
            "verified_source_id",
        ],
    )

    exclusion_rows = read_csv(
        EXCLUSIONS_CSV,
        ["image_path"],
    )

    plan = index_rows(
        plan_rows, "validator_split_plan.csv"
    )

    sources = index_rows(
        source_rows, "validator_source_groups.csv"
    )

    exclusions = set(
        index_rows(
            exclusion_rows, "validator_exclusions.csv"
        )
    )

    if len(plan) != 5911:
        raise ValueError(
            f"Expected 5911 retained records, got {len(plan)}."
        )

    if exclusions.intersection(plan):
        raise ValueError(
            "Excluded duplicates appear in the split plan."
        )

    if not set(sources).issubset(plan):
        raise ValueError(
            "Source-group CSV contains paths absent "
            "from the split plan."
        )

    expected_unsupported = {
        path for path, row in plan.items()
        if row["anatomical_label"].strip()
        == "unsupported"
    }

    if set(sources) != expected_unsupported:
        raise ValueError(
            "Unsupported paths do not match "
            "the source-group review file."
        )

    actual_groups = {
        row["proposed_group_key"].strip()
        for row in sources.values()
    }

    if actual_groups != set(UNSUPPORTED_ASSIGNMENTS):
        raise ValueError(
            "Unexpected source groups.\n"
            f"Actual: {sorted(actual_groups)}\n"
            f"Configured: {sorted(UNSUPPORTED_ASSIGNMENTS)}"
        )

    output_rows = []

    for image_path, row in sorted(plan.items()):
        validate_image_path(image_path)

        label = row["anatomical_label"].strip()

        if label not in CLASSES:
            raise ValueError(
                f"Invalid class for {image_path}: {label}"
            )

        if label == "unsupported":
            source = sources[image_path]

            if source["anatomical_label"].strip() != label:
                raise ValueError(
                    f"Source label mismatch: {image_path}"
                )

            group = source[
                "proposed_group_key"
            ].strip()

            partition = UNSUPPORTED_ASSIGNMENTS[group]

            category = source[
                "negative_category"
            ].strip()

            group_basis = source[
                "group_basis"
            ].strip()

            specimen_id = source.get(
                "verified_source_id", ""
            ).strip()

            if specimen_id:
                raise ValueError(
                    "Verified source IDs require manual "
                    "review before using this provisional "
                    f"configuration: {image_path}"
                )

        else:
            group = row["group_key"].strip()
            partition = row["split"].strip()

            category = ""
            group_basis = row.get(
                "group_basis", ""
            ).strip()

            specimen_id = row.get(
                "specimen_id", ""
            ).strip()

            if not group:
                raise ValueError(
                    f"Missing group key: {image_path}"
                )

        if partition not in PARTITIONS:
            raise ValueError(
                f"Invalid split for {image_path}: "
                f"{partition}"
            )

        output_rows.append({
            "image_path": image_path,
            "anatomical_label": label,
            "negative_category": category,
            "group_key": group,
            "group_basis": group_basis,
            "specimen_id": specimen_id,
            "split": partition,
            "split_status": "experimental_unverified",
        })

    # Confirm that no provisional group appears
    # in more than one partition.
    group_partitions = defaultdict(set)

    for row in output_rows:
        group_partitions[row["group_key"]].add(
            row["split"]
        )

    overlap = {
        group: partitions
        for group, partitions in group_partitions.items()
        if len(partitions) > 1
    }

    if overlap:
        raise ValueError(
            f"Provisional group leakage found: {overlap}"
        )

    # Verify every class has some representation
    # in every partition.
    counts = Counter(
        (row["anatomical_label"], row["split"])
        for row in output_rows
    )

    for label in CLASSES:
        for partition in PARTITIONS:
            if counts[(label, partition)] == 0:
                raise ValueError(
                    f"Missing {label} in {partition}."
                )

    if sum(counts.values()) != len(plan):
        raise ValueError(
            "Record count mismatch."
        )

    # Create only after validation succeeds.
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
    print("EXPERIMENTAL SPLIT DISTRIBUTION")
    print("-" * 60)

    for label in CLASSES:
        print(f"\n{label.upper()}")

        for partition in PARTITIONS:
            print(
                f"  {partition}: "
                f"{counts[(label, partition)]}"
            )

    print()
    print("UNSUPPORTED CATEGORY COVERAGE")
    print("-" * 60)

    category_counts = Counter(
        (row["negative_category"], row["split"])
        for row in output_rows
        if row["anatomical_label"] == "unsupported"
    )

    categories = sorted({
        category
        for category, _ in category_counts
    })

    for category in categories:
        print(f"\n{category}")

        for partition in PARTITIONS:
            print(
                f"  {partition}: "
                f"{category_counts[(category, partition)]}"
            )

    print()
    print("FINAL SUMMARY")
    print("-" * 60)

    for partition in PARTITIONS:
        total = sum(
            counts[(label, partition)]
            for label in CLASSES
        )

        print(f"{partition}: {total} images")

    print(f"TOTAL: {len(output_rows)}")
    print(f"PROVISIONAL GROUPS: {len(group_partitions)}")

    print()
    print("Created:")
    print(OUTPUT_CSV)

    print()
    print("IMPORTANT:")
    print("- Experimental split created successfully.")
    print("- Original splits.csv was not changed.")
    print("- Existing model checkpoints were not changed.")
    print("- Duplicate exclusions remain applied.")
    print("- No training was performed.")
    print("- Group identities are not verified.")
    print("- Other-species validation/test groups are limited.")
    print("- Wrong-region negatives are train-only.")
    print("- This is not an independent final evaluation.")


if __name__ == "__main__":
    main()

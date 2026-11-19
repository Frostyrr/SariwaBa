
"""
SariwaBa Model A - Provisional Group-Aware Split Planner

Creates a review-only train/val/test plan for the validator.

Does not modify:
- Original images
- freshness_labels.csv
- validator_labels.csv
- splits.csv
- Model A or Model B checkpoints

Run from the backend directory:
    python -m ml.prepare_validator_splits

IMPORTANT:
Existing group keys are provisional source-group proxies,
not verified specimen identities. The resulting plan is NOT
automatically approved for final model evaluation.
"""

import csv
from collections import Counter, defaultdict
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent.parent
METADATA_DIR = BASE_DIR / "datasets" / "metadata"

VALIDATOR_CSV = METADATA_DIR / "validator_labels.csv"
SPLITS_CSV = METADATA_DIR / "splits.csv"
EXCLUSIONS_CSV = (
    METADATA_DIR / "validator_exclusions.csv"
)
OUTPUT_CSV = (
    METADATA_DIR / "validator_split_plan.csv"
)

CLASSES = ("eye", "gill", "unsupported")
PARTITIONS = ("train", "val", "test")

TARGETS = {
    "train": 0.70,
    "val": 0.15,
    "test": 0.15,
}


def read_csv(path, required_columns):
    if not path.is_file():
        raise FileNotFoundError(
            f"Missing required file: {path}"
        )

    with path.open(
        "r",
        encoding="utf-8-sig",
        newline="",
    ) as file:
        reader = csv.DictReader(file)

        if not reader.fieldnames:
            raise ValueError(
                f"CSV has no header: {path}"
            )

        missing = set(required_columns) - set(
            reader.fieldnames
        )

        if missing:
            raise ValueError(
                f"{path.name} missing columns: "
                f"{sorted(missing)}"
            )

        return list(reader)


def index_unique(rows, name):
    lookup = {}

    for row in rows:
        image_path = row["image_path"].strip()

        if not image_path:
            raise ValueError(
                f"Empty image_path in {name}"
            )

        if image_path in lookup:
            raise ValueError(
                f"Duplicate image_path in {name}: "
                f"{image_path}"
            )

        lookup[image_path] = row

    return lookup


def load_records():
    validator = read_csv(
        VALIDATOR_CSV,
        (
            "image_path",
            "anatomical_label",
            "group_key",
        ),
    )

    splits = read_csv(
        SPLITS_CSV,
        (
            "image_path",
            "group_key",
            "group_basis",
            "specimen_id",
            "split",
            "split_status",
        ),
    )

    exclusions = read_csv(
        EXCLUSIONS_CSV,
        ("image_path",),
    )

    validator_map = index_unique(
        validator, "validator_labels.csv"
    )
    split_map = index_unique(
        splits, "splits.csv"
    )
    exclusion_map = index_unique(
        exclusions, "validator_exclusions.csv"
    )

    if set(validator_map) != set(split_map):
        raise ValueError(
            "Validator and split manifests have "
            "different image paths."
        )

    if not set(exclusion_map).issubset(
        set(validator_map)
    ):
        raise ValueError(
            "Some exclusions are absent from the "
            "validator manifest."
        )

    if any(
        row["split"].strip()
        for row in splits
    ):
        raise ValueError(
            "splits.csv already contains assignments. "
            "Review existing assignments before "
            "generating a separate plan."
        )

    retained = []

    for image_path, row in validator_map.items():
        if image_path in exclusion_map:
            continue

        label = row["anatomical_label"].strip()

        if label not in CLASSES:
            raise ValueError(
                f"Unknown anatomical label: {label}"
            )

        split_row = split_map[image_path]
        key = split_row["group_key"].strip()

        if not key:
            raise ValueError(
                f"Missing group_key for {image_path}"
            )

        if row["group_key"].strip() != key:
            raise ValueError(
                f"Group key mismatch: {image_path}"
            )

        relative = Path(image_path)

        if relative.is_absolute() or ".." in relative.parts:
            raise ValueError(
                f"Unsafe image path: {image_path}"
            )

        absolute = (BASE_DIR / relative).resolve()

        if not absolute.is_relative_to(
            BASE_DIR.resolve()
        ):
            raise ValueError(
                f"Image path escapes backend: {image_path}"
            )

        if not absolute.is_file():
            raise FileNotFoundError(
                f"Missing image: {absolute}"
            )

        retained.append({
            "image_path": image_path,
            "anatomical_label": label,
            "group_key": key,
            "group_basis": split_row[
                "group_basis"
            ].strip(),
            "specimen_id": split_row[
                "specimen_id"
            ].strip(),
        })

    return retained, len(exclusion_map)


def make_groups(records):
    groups = defaultdict(list)

    for row in records:
        groups[row["group_key"]].append(row)

    # Our current planning strategy uses one label per
    # group. Reject ambiguous mixed-label groups rather
    # than silently separating their images.
    for key, members in groups.items():
        labels = {
            row["anatomical_label"]
            for row in members
        }

        if len(labels) != 1:
            raise ValueError(
                f"Group has multiple labels: {key}. "
                "Requires manual grouping review."
            )

    by_class = defaultdict(list)

    for key, members in groups.items():
        label = members[0]["anatomical_label"]
        by_class[label].append(
            (key, len(members))
        )

    return groups, by_class


def assign_groups(by_class):
    assignments = {}

    for label in CLASSES:
        items = sorted(
            by_class[label],
            key=lambda item: (-item[1], item[0]),
        )

        if len(items) < 3:
            raise ValueError(
                f"{label} has only {len(items)} "
                "groups. Three-way group-aware "
                "splitting requires at least three."
            )

        total = sum(size for _, size in items)
        counts = Counter()

        # First reserve one complete group per split.
        # This prevents a class from disappearing
        # entirely from validation or testing.
        for (key, size), partition in zip(
            items[:3], PARTITIONS
        ):
            assignments[key] = partition
            counts[partition] += size

        # Add the remaining groups using a
        # deterministic size-balance heuristic.
        for key, size in items[3:]:
            def score(partition):
                simulated = {
                    part: counts[part]
                    + (size if part == partition else 0)
                    for part in PARTITIONS
                }

                return sum(
                    (
                        simulated[part] / total
                        - TARGETS[part]
                    ) ** 2
                    for part in PARTITIONS
                )

            best = min(
                PARTITIONS,
                key=lambda part: (
                    score(part),
                    PARTITIONS.index(part),
                ),
            )

            assignments[key] = best
            counts[best] += size

    return assignments


def main():
    print("=" * 60)
    print("SariwaBa Model A - Provisional Split Plan")
    print("=" * 60)

    if OUTPUT_CSV.exists():
        raise FileExistsError(
            "Split plan already exists; "
            "nothing overwritten:\n"
            f"{OUTPUT_CSV}"
        )

    records, excluded_count = load_records()

    groups, by_class = make_groups(records)
    assignments = assign_groups(by_class)

    output_rows = []

    for row in sorted(
        records,
        key=lambda item: item["image_path"],
    ):
        result = dict(row)
        result["split"] = assignments[
            row["group_key"]
        ]
        result["split_status"] = (
            "provisional_review_required"
        )

        output_rows.append(result)

    # Verify that no group spans partitions.
    group_assignments = defaultdict(set)

    for row in output_rows:
        group_assignments[
            row["group_key"]
        ].add(row["split"])

    leaking_groups = [
        key
        for key, assigned in group_assignments.items()
        if len(assigned) != 1
    ]

    if leaking_groups:
        raise ValueError(
            f"Group assignment overlap: {leaking_groups}"
        )

    # Explicitly confirm that all retained Rohu
    # photographs share one provisional partition.
    rohu_partitions = {
        row["split"]
        for row in output_rows
        if (
            row["image_path"].lower().startswith(
                "datasets/unsupported/"
                "other_fish_species/rohu"
            )
        )
    }

    if len(rohu_partitions) > 1:
        raise ValueError(
            "Rohu images were split across partitions."
        )

    columns = [
        "image_path",
        "anatomical_label",
        "group_key",
        "group_basis",
        "specimen_id",
        "split",
        "split_status",
    ]

    # Exclusive creation avoids accidental overwrites.
    with OUTPUT_CSV.open(
        "x",
        newline="",
        encoding="utf-8",
    ) as file:
        writer = csv.DictWriter(
            file,
            fieldnames=columns,
        )

        writer.writeheader()
        writer.writerows(output_rows)

    print(f"Usable images: {len(records)}")
    print(f"Exact duplicates excluded: {excluded_count}")
    print(f"Provisional groups: {len(groups)}")
    print()

    print("PER-CLASS SPLIT DISTRIBUTION")
    print("-" * 60)

    counts = Counter(
        (row["anatomical_label"], row["split"])
        for row in output_rows
    )

    for label in CLASSES:
        total = sum(
            counts[(label, part)]
            for part in PARTITIONS
        )

        print(f"\n{label.upper()} ({total} images)")

        for part in PARTITIONS:
            count = counts[(label, part)]
            percentage = (
                100 * count / total
                if total else 0
            )

            print(
                f"  {part:5}: {count:5} "
                f"({percentage:.1f}%)"
            )

    print()
    print(
        "Rohu partitions:",
        sorted(rohu_partitions)
        if rohu_partitions else "none",
    )

    print("\nOutput:")
    print(OUTPUT_CSV)

    print()
    print("IMPORTANT:")
    print("- This is a REVIEW-ONLY split plan.")
    print("- Existing splits.csv was not modified.")
    print("- Original image files were not modified.")
    print("- Group keys are NOT verified specimen IDs.")
    print("- Similarity across other groups is unverified.")
    print("- Split balance may differ from 70/15/15.")
    print("- Training must wait for split review.")
    print("- Model B remains unchanged.")


if __name__ == "__main__":
    main()

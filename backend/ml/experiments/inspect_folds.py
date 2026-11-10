from pathlib import Path
from collections import defaultdict
import random
import re

from torchvision import datasets


# ============================================================
# CONFIG
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "datasets" / "tilapia"

NUM_FOLDS = 5
RANDOM_SEED = 42
BLOCK_SIZE = 50


# ============================================================
# LOAD DATASET EXACTLY LIKE cross_validate.py
# ============================================================

base_dataset = datasets.ImageFolder(
    root=DATA_DIR
)


print("=" * 80)
print("SariwaBa Exact Cross-Validation Fold Inspection")
print("=" * 80)

print(f"\nDataset: {DATA_DIR}")
print(f"Classes: {base_dataset.classes}")
print(f"Class mapping: {base_dataset.class_to_idx}")
print(f"Total images: {len(base_dataset)}")


# ============================================================
# SAME GROUP FUNCTION USED BY cross_validate.py
# ============================================================

def create_group_key(path_string):
    path = Path(path_string)
    parts = path.parts

    if "Fresh" in parts:
        return f"Fresh::{path.parent}"

    if "NonFresh" in parts:

        match = re.match(r"(\d+)", path.stem)

        if match:
            image_number = int(match.group(1))
        else:
            image_number = 0

        block_number = (
            image_number // BLOCK_SIZE
        )

        return (
            f"NonFresh::{path.parent}::"
            f"block_{block_number}"
        )

    return str(path.parent)


# ============================================================
# CREATE GROUPS IN EXACT ImageFolder SAMPLE ORDER
# ============================================================

groups_by_class = defaultdict(
    lambda: defaultdict(list)
)


for index, (path, class_index) in enumerate(
    base_dataset.samples
):

    group_key = create_group_key(
        path
    )

    groups_by_class[
        class_index
    ][
        group_key
    ].append(
        index
    )


print("\nDetected groups:")

for class_index, class_name in enumerate(
    base_dataset.classes
):

    print(
        f"{class_name}: "
        f"{len(groups_by_class[class_index])} groups"
    )


# ============================================================
# EXACT SAME FOLD ASSIGNMENT AS cross_validate.py
# ============================================================

fold_validation_indices = [
    []
    for _ in range(NUM_FOLDS)
]


fold_validation_groups = [
    []
    for _ in range(NUM_FOLDS)
]


for class_index in range(
    len(base_dataset.classes)
):

    groups = list(
        groups_by_class[
            class_index
        ].keys()
    )

    random.Random(
        RANDOM_SEED + class_index
    ).shuffle(groups)

    for position, group_key in enumerate(
        groups
    ):

        fold_index = (
            position % NUM_FOLDS
        )

        fold_validation_indices[
            fold_index
        ].extend(
            groups_by_class[
                class_index
            ][
                group_key
            ]
        )

        fold_validation_groups[
            fold_index
        ].append(
            (
                class_index,
                group_key,
            )
        )


all_indices = set(
    range(len(base_dataset))
)


# ============================================================
# PRINT EXACT FOLD SIZES
# ============================================================

print("\n" + "=" * 80)
print("EXACT FOLD SIZES")
print("=" * 80)


for fold_index in range(
    NUM_FOLDS
):

    validation_indices = set(
        fold_validation_indices[
            fold_index
        ]
    )

    training_indices = (
        all_indices
        - validation_indices
    )

    print(
        f"Fold {fold_index + 1}: "
        f"Train={len(training_indices)}, "
        f"Validation={len(validation_indices)}"
    )


# ============================================================
# PRINT GROUPS IN EACH FOLD
# ============================================================

for fold_index in range(
    NUM_FOLDS
):

    print("\n" + "=" * 80)
    print(f"FOLD {fold_index + 1}")
    print("=" * 80)

    class_totals = {
        class_name: 0
        for class_name
        in base_dataset.classes
    }

    for class_index, group_key in (
        fold_validation_groups[
            fold_index
        ]
    ):

        class_name = (
            base_dataset.classes[
                class_index
            ]
        )

        group_indices = (
            groups_by_class[
                class_index
            ][
                group_key
            ]
        )

        image_count = len(
            group_indices
        )

        class_totals[
            class_name
        ] += image_count

        print(
            f"\nClass: {class_name}"
        )

        print(
            f"Group: {group_key}"
        )

        print(
            f"Images: {image_count}"
        )

        first_index = (
            group_indices[0]
        )

        last_index = (
            group_indices[-1]
        )

        print(
            "First image:",
            base_dataset.samples[
                first_index
            ][0],
        )

        print(
            "Last image:",
            base_dataset.samples[
                last_index
            ][0],
        )


    print("\nClass totals:")

    for class_name in (
        base_dataset.classes
    ):

        print(
            f"{class_name}: "
            f"{class_totals[class_name]}"
        )

    print(
        "Total validation images:",
        len(
            fold_validation_indices[
                fold_index
            ]
        ),
    )


# ============================================================
# FOLD 4 DETAILED SUMMARY
# ============================================================

TARGET_FOLD = 3


print("\n" + "#" * 80)
print("ACTUAL FOLD 4 DETAILED SUMMARY")
print("#" * 80)


for class_index, group_key in (
    fold_validation_groups[
        TARGET_FOLD
    ]
):

    class_name = (
        base_dataset.classes[
            class_index
        ]
    )

    group_indices = (
        groups_by_class[
            class_index
        ][
            group_key
        ]
    )

    print(
        f"\nClass: {class_name}"
    )

    print(
        f"Group: {group_key}"
    )

    print(
        f"Images: {len(group_indices)}"
    )

    print(
        "First image:",
        base_dataset.samples[
            group_indices[0]
        ][0],
    )

    print(
        "Last image:",
        base_dataset.samples[
            group_indices[-1]
        ][0],
    )


print("\nInspection complete.")
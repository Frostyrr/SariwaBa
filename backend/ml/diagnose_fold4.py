from pathlib import Path
from collections import Counter, defaultdict
import csv
import random
import re

import numpy as np
import torch
from torch import nn, optim
from torch.utils.data import DataLoader, Subset
from torchvision import datasets, models, transforms


# ============================================================
# CONFIG
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "datasets" / "tilapia"

RESULTS_DIR = BASE_DIR / "ml" / "results"
RESULTS_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

IMAGE_SIZE = 224
BATCH_SIZE = 16
EPOCHS = 5
LEARNING_RATE = 0.001

NUM_FOLDS = 5
TARGET_FOLD = 4

RANDOM_SEED = 42
BLOCK_SIZE = 50


DEVICE = torch.device(
    "cuda"
    if torch.cuda.is_available()
    else "cpu"
)


# ============================================================
# RANDOM SEEDS
# ============================================================

random.seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)
torch.manual_seed(RANDOM_SEED)

if torch.cuda.is_available():
    torch.cuda.manual_seed_all(
        RANDOM_SEED
    )


# ============================================================
# START
# ============================================================

print("=" * 75)
print("SariwaBa Fold 4 Diagnostic")
print("=" * 75)

print(f"Device: {DEVICE}")
print(f"Dataset: {DATA_DIR}")


# ============================================================
# TRANSFORMS
# ============================================================

train_transform = transforms.Compose([
    transforms.RandomResizedCrop(
        IMAGE_SIZE,
        scale=(0.75, 1.0),
        ratio=(0.75, 1.33),
    ),

    transforms.RandomHorizontalFlip(),

    transforms.RandomRotation(
        12
    ),

    transforms.ColorJitter(
        brightness=0.30,
        contrast=0.20,
        saturation=0.20,
    ),

    transforms.ToTensor(),

    transforms.Normalize(
        mean=[
            0.485,
            0.456,
            0.406,
        ],
        std=[
            0.229,
            0.224,
            0.225,
        ],
    ),
])


eval_transform = transforms.Compose([
    transforms.Resize(
        (IMAGE_SIZE, IMAGE_SIZE)
    ),

    transforms.ToTensor(),

    transforms.Normalize(
        mean=[
            0.485,
            0.456,
            0.406,
        ],
        std=[
            0.229,
            0.224,
            0.225,
        ],
    ),
])


# ============================================================
# LOAD DATASET
# ============================================================

base_dataset = datasets.ImageFolder(
    root=DATA_DIR
)

print("\nClasses:")
print(base_dataset.classes)

print(
    f"\nTotal images: "
    f"{len(base_dataset)}"
)


# ============================================================
# GROUP KEY
# ============================================================

def create_group_key(path_string):

    path = Path(path_string)
    parts = path.parts

    if "Fresh" in parts:

        return (
            f"Fresh::{path.parent}"
        )


    if "NonFresh" in parts:

        match = re.match(
            r"(\d+)",
            path.stem,
        )

        if match:
            image_number = int(
                match.group(1)
            )
        else:
            image_number = 0


        block_number = (
            image_number
            // BLOCK_SIZE
        )


        return (
            f"NonFresh::"
            f"{path.parent}::"
            f"block_{block_number}"
        )


    return str(
        path.parent
    )


# ============================================================
# COLLECT GROUPS
# ============================================================

groups_by_class = defaultdict(
    lambda: defaultdict(list)
)


for index, (
    path,
    class_index,
) in enumerate(
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


print(
    "\nDetected grouped sequences:"
)


for class_index, class_name in enumerate(
    base_dataset.classes
):

    print(
        f"{class_name}: "
        f"{len(groups_by_class[class_index])} groups"
    )


# ============================================================
# BUILD SAME 5 FOLDS AS CROSS_VALIDATE.PY
# ============================================================

fold_validation_indices = [
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


    group_randomizer = random.Random(
        RANDOM_SEED
        + class_index
    )


    group_randomizer.shuffle(
        groups
    )


    for position, group_key in enumerate(
        groups
    ):

        fold_index = (
            position
            % NUM_FOLDS
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


# Fold numbers are shown to users as 1-5,
# but Python list indexes are 0-4.

target_fold_index = (
    TARGET_FOLD - 1
)


validation_indices = list(
    fold_validation_indices[
        target_fold_index
    ]
)


validation_index_set = set(
    validation_indices
)


all_indices = set(
    range(
        len(base_dataset)
    )
)


training_indices = list(
    all_indices
    - validation_index_set
)


print(
    f"\nFold {TARGET_FOLD}:"
)

print(
    f"Training images: "
    f"{len(training_indices)}"
)

print(
    f"Validation images: "
    f"{len(validation_indices)}"
)


# ============================================================
# VERIFY NO GROUP LEAKAGE
# ============================================================

def groups_from_indices(indices):

    result = set()

    for index in indices:

        path, _ = (
            base_dataset.samples[
                index
            ]
        )

        result.add(
            create_group_key(
                path
            )
        )

    return result


training_groups = groups_from_indices(
    training_indices
)

validation_groups = groups_from_indices(
    validation_indices
)


assert training_groups.isdisjoint(
    validation_groups
), "Group leakage detected."


print(
    "Group leakage check: PASSED"
)


# ============================================================
# DATASETS
# ============================================================

train_full_dataset = datasets.ImageFolder(
    root=DATA_DIR,
    transform=train_transform,
)


eval_full_dataset = datasets.ImageFolder(
    root=DATA_DIR,
    transform=eval_transform,
)


train_dataset = Subset(
    train_full_dataset,
    training_indices,
)


validation_dataset = Subset(
    eval_full_dataset,
    validation_indices,
)


train_loader = DataLoader(
    train_dataset,
    batch_size=BATCH_SIZE,
    shuffle=True,
)


validation_loader = DataLoader(
    validation_dataset,
    batch_size=BATCH_SIZE,
    shuffle=False,
)


# ============================================================
# CLASS WEIGHTS
# ============================================================

train_targets = [
    base_dataset.samples[
        index
    ][1]
    for index
    in training_indices
]


class_counts = Counter(
    train_targets
)


number_of_classes = len(
    base_dataset.classes
)


total_training_images = len(
    train_targets
)


class_weights = []


for class_index in range(
    number_of_classes
):

    class_count = class_counts[
        class_index
    ]

    weight = (
        total_training_images
        /
        (
            number_of_classes
            * class_count
        )
    )

    class_weights.append(
        weight
    )


class_weights = torch.tensor(
    class_weights,
    dtype=torch.float32,
).to(
    DEVICE
)


print(
    "\nTraining class counts:"
)


for class_index, class_name in enumerate(
    base_dataset.classes
):

    print(
        f"{class_name}: "
        f"{class_counts[class_index]}"
    )


print(
    f"Class weights: "
    f"{class_weights}"
)


# ============================================================
# MODEL
# ============================================================

pretrained_weights = (
    models
    .MobileNet_V3_Small_Weights
    .DEFAULT
)


model = models.mobilenet_v3_small(
    weights=pretrained_weights
)


# Freeze all feature layers first
for parameter in (
    model.features.parameters()
):
    parameter.requires_grad = False


# Unfreeze the last two MobileNetV3 feature blocks
for parameter in (
    model.features[-2:].parameters()
):
    parameter.requires_grad = True

number_of_features = (
    model.classifier[3].in_features
)


model.classifier[3] = nn.Linear(
    number_of_features,
    number_of_classes,
)


model = model.to(
    DEVICE
)


# ============================================================
# LOSS + OPTIMIZER
# ============================================================

criterion = nn.CrossEntropyLoss(
    weight=class_weights
)


optimizer = optim.Adam([
    {
        "params": model.classifier.parameters(),
        "lr": 0.001,
    },
    {
        "params": model.features[-2:].parameters(),
        "lr": 0.0001,
    },
])


# ============================================================
# TRAIN 5 EPOCHS
# ============================================================

print(
    "\nTraining Fold 4..."
)


for epoch in range(
    EPOCHS
):

    model.train()

    running_loss = 0.0
    training_correct = 0
    training_total = 0


    for images, labels in (
        train_loader
    ):

        images = images.to(
            DEVICE
        )

        labels = labels.to(
            DEVICE
        )


        optimizer.zero_grad()


        outputs = model(
            images
        )


        loss = criterion(
            outputs,
            labels
        )


        loss.backward()
        optimizer.step()


        running_loss += (
            loss.item()
        )


        _, predictions = torch.max(
            outputs,
            1
        )


        training_total += (
            labels.size(0)
        )


        training_correct += (
            predictions
            == labels
        ).sum().item()


    training_accuracy = (
        100
        * training_correct
        / training_total
    )


    average_loss = (
        running_loss
        / len(train_loader)
    )


    # --------------------------------------------------------
    # VALIDATION MONITORING
    # --------------------------------------------------------

    model.eval()

    validation_correct = 0
    validation_total = 0


    with torch.no_grad():

        for images, labels in (
            validation_loader
        ):

            images = images.to(
                DEVICE
            )

            labels = labels.to(
                DEVICE
            )


            outputs = model(
                images
            )


            _, predictions = torch.max(
                outputs,
                1
            )


            validation_total += (
                labels.size(0)
            )


            validation_correct += (
                predictions
                == labels
            ).sum().item()


    validation_accuracy = (
        100
        * validation_correct
        / validation_total
    )


    print(
        f"Epoch "
        f"[{epoch + 1}/{EPOCHS}] "
        f"Loss: "
        f"{average_loss:.4f} "
        f"Train Acc: "
        f"{training_accuracy:.2f}% "
        f"Val Acc: "
        f"{validation_accuracy:.2f}%"
    )


# ============================================================
# FINAL PER-IMAGE PREDICTIONS
# ============================================================

model.eval()


prediction_by_index = {}


with torch.no_grad():

    for subset_position in range(
        len(validation_dataset)
    ):

        image, true_label = (
            validation_dataset[
                subset_position
            ]
        )


        original_index = (
            validation_indices[
                subset_position
            ]
        )


        image = image.unsqueeze(
            0
        ).to(
            DEVICE
        )


        outputs = model(
            image
        )


        _, predicted_label = torch.max(
            outputs,
            1
        )


        prediction_by_index[
            original_index
        ] = (
            true_label,
            predicted_label.item(),
        )


# ============================================================
# GROUP-LEVEL RESULTS
# ============================================================

group_results = defaultdict(
    lambda: {
        "class_name": None,
        "total": 0,
        "correct": 0,
        "wrong": 0,
    }
)


for index in validation_indices:

    path, true_class_index = (
        base_dataset.samples[
            index
        ]
    )


    group_key = create_group_key(
        path
    )


    true_label, predicted_label = (
        prediction_by_index[
            index
        ]
    )


    class_name = (
        base_dataset.classes[
            true_class_index
        ]
    )


    group_results[
        group_key
    ][
        "class_name"
    ] = class_name


    group_results[
        group_key
    ][
        "total"
    ] += 1


    if true_label == predicted_label:

        group_results[
            group_key
        ][
            "correct"
        ] += 1

    else:

        group_results[
            group_key
        ][
            "wrong"
        ] += 1


# ============================================================
# PRINT GROUP RESULTS
# ============================================================

print(
    "\n"
    + "=" * 75
)

print(
    "FOLD 4 GROUP-LEVEL DIAGNOSTIC"
)

print(
    "=" * 75
)


sorted_results = sorted(
    group_results.items(),
    key=lambda item: (
        item[1]["class_name"],
        (
            item[1]["correct"]
            / item[1]["total"]
        ),
    ),
)


for group_key, result in (
    sorted_results
):

    accuracy = (
        100
        * result["correct"]
        / result["total"]
    )


    print(
        f"\nClass: "
        f"{result['class_name']}"
    )

    print(
        f"Group: "
        f"{group_key}"
    )

    print(
        f"Images: "
        f"{result['total']}"
    )

    print(
        f"Correct: "
        f"{result['correct']}"
    )

    print(
        f"Wrong: "
        f"{result['wrong']}"
    )

    print(
        f"Accuracy: "
        f"{accuracy:.2f}%"
    )


# ============================================================
# CLASS SUMMARY
# ============================================================

print(
    "\n"
    + "=" * 75
)

print(
    "FOLD 4 CLASS SUMMARY"
)

print(
    "=" * 75
)


class_summary = defaultdict(
    lambda: {
        "total": 0,
        "correct": 0,
    }
)


for result in group_results.values():

    class_name = result[
        "class_name"
    ]


    class_summary[
        class_name
    ][
        "total"
    ] += result[
        "total"
    ]


    class_summary[
        class_name
    ][
        "correct"
    ] += result[
        "correct"
    ]


for class_name in (
    base_dataset.classes
):

    total = (
        class_summary[
            class_name
        ][
            "total"
        ]
    )

    correct = (
        class_summary[
            class_name
        ][
            "correct"
        ]
    )


    accuracy = (
        100
        * correct
        / total
        if total > 0
        else 0
    )


    print(
        f"{class_name}: "
        f"{correct}/{total} "
        f"correct "
        f"({accuracy:.2f}%)"
    )


# ============================================================
# OVERALL FOLD ACCURACY
# ============================================================

overall_correct = sum(
    result["correct"]
    for result
    in group_results.values()
)


overall_total = sum(
    result["total"]
    for result
    in group_results.values()
)


overall_accuracy = (
    100
    * overall_correct
    / overall_total
)


print(
    f"\nOverall Fold 4 Accuracy: "
    f"{overall_accuracy:.2f}%"
)


# ============================================================
# SAVE GROUP RESULTS CSV
# ============================================================

csv_path = (
    RESULTS_DIR
    / "fold4_group_diagnostic.csv"
)


with open(
    csv_path,
    "w",
    newline="",
    encoding="utf-8",
) as csv_file:

    writer = csv.writer(
        csv_file
    )


    writer.writerow([
        "Class",
        "Group",
        "Images",
        "Correct",
        "Wrong",
        "Accuracy (%)",
    ])


    for group_key, result in (
        sorted_results
    ):

        accuracy = (
            100
            * result["correct"]
            / result["total"]
        )


        writer.writerow([
            result["class_name"],
            group_key,
            result["total"],
            result["correct"],
            result["wrong"],
            round(
                accuracy,
                4,
            ),
        ])


print(
    f"\nCSV saved to:"
)

print(
    csv_path
)


print(
    "\nFold 4 diagnostic complete."
)
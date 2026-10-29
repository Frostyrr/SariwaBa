from pathlib import Path
from collections import defaultdict
import random
import csv
import re

import torch
from torch import nn
from torch.utils.data import DataLoader, Subset
from torchvision import datasets, models, transforms

import matplotlib.pyplot as plt

from sklearn.metrics import (
    classification_report,
    confusion_matrix,
)


# ============================================================
# CONFIG
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent

DATA_DIR = (
    BASE_DIR
    / "datasets"
    / "tilapia"
)

MODEL_PATH = (
    BASE_DIR
    / "ml"
    / "models"
    / "sariwaba_mobilenetv3_best.pth"
)

RESULTS_DIR = (
    BASE_DIR
    / "ml"
    / "results"
    / "final"
)

RESULTS_DIR.mkdir(
    parents=True,
    exist_ok=True,
)


IMAGE_SIZE = 224
BATCH_SIZE = 16
RANDOM_SEED = 42
BLOCK_SIZE = 50


DEVICE = torch.device(
    "cuda"
    if torch.cuda.is_available()
    else "cpu"
)


random.seed(
    RANDOM_SEED
)


# ============================================================
# TRANSFORM
# ============================================================

transform = transforms.Compose([
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


eval_dataset = datasets.ImageFolder(
    root=DATA_DIR,
    transform=transform,
)


print("=" * 60)
print("SariwaBa Model Evaluation")
print("=" * 60)

print(
    f"Device: "
    f"{DEVICE}"
)

print(
    f"Dataset: "
    f"{DATA_DIR}"
)

print(
    f"Model: "
    f"{MODEL_PATH}"
)

print(
    f"Results folder: "
    f"{RESULTS_DIR}"
)


# ============================================================
# SAME GROUPING LOGIC AS TRAINING
# ============================================================

def create_group_key(path_string):

    path = Path(
        path_string
    )

    parts = path.parts


    # --------------------------------------------------------
    # FRESH
    # --------------------------------------------------------

    if "Fresh" in parts:

        return (
            f"Fresh::{path.parent}"
        )


    # --------------------------------------------------------
    # NONFRESH
    # --------------------------------------------------------

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


# ============================================================
# RECREATE TEST SPLIT
# ============================================================

test_indices = []


for class_index in range(
    len(base_dataset.classes)
):

    groups = list(
        groups_by_class[
            class_index
        ].keys()
    )


    random.shuffle(
        groups
    )


    number_of_groups = len(
        groups
    )


    train_count = max(
        1,
        int(
            number_of_groups
            * 0.70
        )
    )


    val_count = max(
        1,
        int(
            number_of_groups
            * 0.15
        )
    )


    if (
        train_count
        + val_count
        >= number_of_groups
    ):

        train_count = max(
            1,
            number_of_groups - 2
        )

        val_count = 1


    test_groups = groups[
        train_count + val_count:
    ]


    for group in test_groups:

        test_indices.extend(
            groups_by_class[
                class_index
            ][
                group
            ]
        )


test_dataset = Subset(
    eval_dataset,
    test_indices,
)


test_loader = DataLoader(
    test_dataset,
    batch_size=BATCH_SIZE,
    shuffle=False,
)


# ============================================================
# LOAD MODEL
# ============================================================

checkpoint = torch.load(
    MODEL_PATH,
    map_location=DEVICE,
    weights_only=False,
)


classes = checkpoint[
    "classes"
]


model = models.mobilenet_v3_small(
    weights=None
)


num_features = (
    model.classifier[
        3
    ].in_features
)


model.classifier[3] = nn.Linear(
    num_features,
    len(classes),
)


model.load_state_dict(
    checkpoint[
        "model_state_dict"
    ]
)


model = model.to(
    DEVICE
)


model.eval()


# ============================================================
# EVALUATE
# ============================================================

all_labels = []
all_predictions = []


with torch.no_grad():

    for images, labels in (
        test_loader
    ):

        images = images.to(
            DEVICE
        )


        outputs = model(
            images
        )


        _, predictions = torch.max(
            outputs,
            1
        )


        all_labels.extend(
            labels.tolist()
        )


        all_predictions.extend(
            predictions
            .cpu()
            .tolist()
        )


# ============================================================
# CONFUSION MATRIX
# ============================================================

matrix = confusion_matrix(
    all_labels,
    all_predictions,
)


print(
    "\nClasses:"
)

print(
    classes
)


print(
    f"\nTest images: "
    f"{len(all_labels)}"
)


print(
    "\nConfusion Matrix:"
)

print(
    matrix
)


# ============================================================
# CLASSIFICATION REPORT
# ============================================================

print(
    "\nClassification Report:"
)


print(
    classification_report(
        all_labels,
        all_predictions,
        target_names=classes,
        digits=4,
        zero_division=0,
    )
)


# ============================================================
# ACCURACY
# ============================================================

correct = sum(
    true == predicted
    for true, predicted
    in zip(
        all_labels,
        all_predictions,
    )
)


accuracy = (
    100
    * correct
    / len(all_labels)
)


print(
    f"\nOverall Test Accuracy: "
    f"{accuracy:.2f}%"
)


# ============================================================
# SAVE CONFUSION MATRIX CSV
# ============================================================

csv_path = (
    RESULTS_DIR
    / "confusion_matrix.csv"
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
        "Actual / Predicted",
        *classes,
    ])


    for row_index, class_name in enumerate(
        classes
    ):

        writer.writerow([
            class_name,
            *matrix[
                row_index
            ].tolist(),
        ])


print(
    f"\nConfusion matrix CSV saved:"
)

print(
    csv_path
)


# ============================================================
# SAVE CONFUSION MATRIX PNG
# ============================================================

figure, axis = plt.subplots(
    figsize=(6, 5)
)


matrix_image = axis.imshow(
    matrix
)


axis.set_title(
    "SariwaBa Fish Freshness "
    "Confusion Matrix"
)


axis.set_xlabel(
    "Predicted Label"
)


axis.set_ylabel(
    "Actual Label"
)


axis.set_xticks(
    range(
        len(classes)
    )
)


axis.set_yticks(
    range(
        len(classes)
    )
)


axis.set_xticklabels(
    classes
)


axis.set_yticklabels(
    classes
)


# Put numbers inside each matrix cell
for row in range(
    matrix.shape[0]
):

    for column in range(
        matrix.shape[1]
    ):

        axis.text(
            column,
            row,
            str(
                matrix[
                    row,
                    column
                ]
            ),
            ha="center",
            va="center",
        )


figure.colorbar(
    matrix_image,
    ax=axis,
)


figure.tight_layout()


png_path = (
    RESULTS_DIR
    / "confusion_matrix.png"
)


figure.savefig(
    png_path,
    dpi=300,
    bbox_inches="tight",
)


plt.close(
    figure
)


print(
    f"\nConfusion matrix PNG saved:"
)

print(
    png_path
)


# ============================================================
# FINISH
# ============================================================

print(
    "\n"
    + "=" * 60
)

print(
    "Evaluation complete."
)

print(
    "=" * 60
)
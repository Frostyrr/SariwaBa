from pathlib import Path
from collections import Counter, defaultdict
import random

import torch
from torch import nn
from torch.utils.data import DataLoader, Subset
from torchvision import datasets, models, transforms
import re

from sklearn.metrics import (
    classification_report,
    confusion_matrix,
)


BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "datasets" / "tilapia"

MODEL_PATH = (
    BASE_DIR
    / "ml"
    / "models"
    / "sariwaba_mobilenetv3_best.pth"
)

IMAGE_SIZE = 224
BATCH_SIZE = 16
RANDOM_SEED = 42
BLOCK_SIZE = 50

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

random.seed(RANDOM_SEED)


# ============================================================
# TRANSFORM
# ============================================================

transform = transforms.Compose([
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
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


# ============================================================
# SAME GROUPING LOGIC AS TRAINING
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

        block_number = image_number // BLOCK_SIZE

        return (
            f"NonFresh::{path.parent}::"
            f"block_{block_number}"
        )

    return str(path.parent)


groups_by_class = defaultdict(
    lambda: defaultdict(list)
)

for index, (path, class_index) in enumerate(
    base_dataset.samples
):
    group_key = create_group_key(path)

    groups_by_class[class_index][group_key].append(
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
        groups_by_class[class_index].keys()
    )

    random.shuffle(groups)

    number_of_groups = len(groups)

    train_count = max(
        1,
        int(number_of_groups * 0.70)
    )

    val_count = max(
        1,
        int(number_of_groups * 0.15)
    )

    if train_count + val_count >= number_of_groups:

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
            groups_by_class[class_index][group]
        )


test_dataset = Subset(
    eval_dataset,
    test_indices
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


classes = checkpoint["classes"]

model = models.mobilenet_v3_small(
    weights=None
)

num_features = model.classifier[3].in_features

model.classifier[3] = nn.Linear(
    num_features,
    len(classes),
)

model.load_state_dict(
    checkpoint["model_state_dict"]
)

model = model.to(DEVICE)

model.eval()


# ============================================================
# EVALUATE
# ============================================================

all_labels = []
all_predictions = []


with torch.no_grad():

    for images, labels in test_loader:

        images = images.to(DEVICE)

        outputs = model(images)

        _, predictions = torch.max(
            outputs,
            1
        )

        all_labels.extend(
            labels.tolist()
        )

        all_predictions.extend(
            predictions.cpu().tolist()
        )


# ============================================================
# RESULTS
# ============================================================

print("=" * 60)
print("SariwaBa Model Evaluation")
print("=" * 60)

print("\nClasses:")
print(classes)

print(
    f"\nTest images: "
    f"{len(all_labels)}"
)


print("\nConfusion Matrix:")

matrix = confusion_matrix(
    all_labels,
    all_predictions
)

print(matrix)


print("\nClassification Report:")

print(
    classification_report(
        all_labels,
        all_predictions,
        target_names=classes,
        digits=4,
    )
)


correct = sum(
    true == predicted
    for true, predicted
    in zip(
        all_labels,
        all_predictions
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
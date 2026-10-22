from pathlib import Path
from collections import Counter, defaultdict
import random

import torch
from torch import nn, optim
from torch.utils.data import DataLoader, Subset
from torchvision import datasets, models, transforms


# ============================================================
# CONFIG
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "datasets" / "tilapia"

MODEL_DIR = BASE_DIR / "ml" / "models"
MODEL_DIR.mkdir(parents=True, exist_ok=True)

IMAGE_SIZE = 224
BATCH_SIZE = 16
EPOCHS = 15
LEARNING_RATE = 0.001

RANDOM_SEED = 42

# Consecutive frames in NonFresh folders are grouped together.
# 50 means images 0001-0050 stay together, etc.
BLOCK_SIZE = 50

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

random.seed(RANDOM_SEED)
torch.manual_seed(RANDOM_SEED)


print("=" * 60)
print("SariwaBa Grouped Fish Freshness Training")
print("=" * 60)

print(f"Device: {DEVICE}")
print(f"Dataset: {DATA_DIR}")


# ============================================================
# TRANSFORMS
# ============================================================

train_transform = transforms.Compose([
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),

    transforms.RandomHorizontalFlip(),

    transforms.RandomRotation(10),

    transforms.ColorJitter(
        brightness=0.15,
        contrast=0.15,
        saturation=0.15,
    ),

    transforms.ToTensor(),

    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])


eval_transform = transforms.Compose([
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

print("\nClasses:")
print(base_dataset.classes)

print("\nClass mapping:")
print(base_dataset.class_to_idx)

print(f"\nTotal images: {len(base_dataset)}")


# ============================================================
# CREATE CAPTURE GROUP
# ============================================================

def create_group_key(path_string):
    path = Path(path_string)

    parts = path.parts

    # --------------------------------------------------------
    # FRESH
    # --------------------------------------------------------
    #
    # Example:
    # Fresh/Day 1/Eyes/1_Eyes/0235.jpg
    #
    # Keep the entire 1_Eyes directory together.
    #
    if "Fresh" in parts:

        parent = path.parent

        return f"Fresh::{parent}"


    # --------------------------------------------------------
    # NONFRESH
    # --------------------------------------------------------
    #
    # NonFresh does not have specimen-number directories.
    # Therefore group neighboring numbered frames into blocks.
    #
    # Example:
    # 0001-0050 -> block 0
    # 0051-0100 -> block 1
    # etc.
    #
    if "NonFresh" in parts:

        try:
            image_number = int(path.stem)
        except ValueError:
            image_number = 0

        block_number = image_number // BLOCK_SIZE

        parent = path.parent

        return (
            f"NonFresh::{parent}::"
            f"block_{block_number}"
        )


    return str(path.parent)


# ============================================================
# COLLECT GROUPS BY CLASS
# ============================================================

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


print("\nDetected grouped sequences:")

for class_index, class_name in enumerate(
    base_dataset.classes
):

    groups = groups_by_class[class_index]

    print(
        f"{class_name}: "
        f"{len(groups)} groups"
    )


# ============================================================
# SPLIT GROUPS
# ============================================================

train_indices = []
val_indices = []
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


    # Ensure at least one test group
    if train_count + val_count >= number_of_groups:

        train_count = max(
            1,
            number_of_groups - 2
        )

        val_count = 1


    train_groups = groups[
        :train_count
    ]

    val_groups = groups[
        train_count:
        train_count + val_count
    ]

    test_groups = groups[
        train_count + val_count:
    ]


    for group in train_groups:

        train_indices.extend(
            groups_by_class[class_index][group]
        )


    for group in val_groups:

        val_indices.extend(
            groups_by_class[class_index][group]
        )


    for group in test_groups:

        test_indices.extend(
            groups_by_class[class_index][group]
        )


print("\nGrouped dataset split:")

print(
    f"Training images:   "
    f"{len(train_indices)}"
)

print(
    f"Validation images: "
    f"{len(val_indices)}"
)

print(
    f"Testing images:    "
    f"{len(test_indices)}"
)


# ============================================================
# VERIFY NO GROUP LEAKAGE
# ============================================================

def get_groups(indices):

    result = set()

    for index in indices:

        path, _ = base_dataset.samples[index]

        result.add(
            create_group_key(path)
        )

    return result


train_groups = get_groups(train_indices)
val_groups = get_groups(val_indices)
test_groups = get_groups(test_indices)


assert train_groups.isdisjoint(
    val_groups
)

assert train_groups.isdisjoint(
    test_groups
)

assert val_groups.isdisjoint(
    test_groups
)


print(
    "\nGroup leakage check: PASSED"
)


# ============================================================
# DATASETS
# ============================================================

train_full_dataset = datasets.ImageFolder(
    DATA_DIR,
    transform=train_transform,
)

eval_full_dataset = datasets.ImageFolder(
    DATA_DIR,
    transform=eval_transform,
)


train_dataset = Subset(
    train_full_dataset,
    train_indices,
)

val_dataset = Subset(
    eval_full_dataset,
    val_indices,
)

test_dataset = Subset(
    eval_full_dataset,
    test_indices,
)


train_loader = DataLoader(
    train_dataset,
    batch_size=BATCH_SIZE,
    shuffle=True,
)

val_loader = DataLoader(
    val_dataset,
    batch_size=BATCH_SIZE,
    shuffle=False,
)

test_loader = DataLoader(
    test_dataset,
    batch_size=BATCH_SIZE,
    shuffle=False,
)


# ============================================================
# CLASS WEIGHTS
# ============================================================

train_targets = [
    base_dataset.samples[index][1]
    for index in train_indices
]

counts = Counter(train_targets)

number_of_classes = len(
    base_dataset.classes
)

total_train = len(train_targets)


weights = []

for class_index in range(
    number_of_classes
):

    count = counts[class_index]

    weight = (
        total_train /
        (
            number_of_classes
            * count
        )
    )

    weights.append(weight)


class_weights = torch.tensor(
    weights,
    dtype=torch.float32,
).to(DEVICE)


print("\nTraining class counts:")

for class_index, class_name in enumerate(
    base_dataset.classes
):

    print(
        f"{class_name}: "
        f"{counts[class_index]}"
    )


print("\nClass weights:")
print(class_weights)


# ============================================================
# MODEL
# ============================================================

weights = (
    models.MobileNet_V3_Small_Weights.DEFAULT
)


model = models.mobilenet_v3_small(
    weights=weights
)


for parameter in model.features.parameters():

    parameter.requires_grad = False


num_features = (
    model.classifier[3].in_features
)


model.classifier[3] = nn.Linear(
    num_features,
    number_of_classes,
)


model = model.to(DEVICE)


criterion = nn.CrossEntropyLoss(
    weight=class_weights
)


optimizer = optim.Adam(
    model.classifier.parameters(),
    lr=LEARNING_RATE,
)


# ============================================================
# TRAIN
# ============================================================

best_val_accuracy = 0.0


for epoch in range(EPOCHS):

    model.train()

    running_loss = 0.0

    correct = 0
    total = 0


    for images, labels in train_loader:

        images = images.to(DEVICE)
        labels = labels.to(DEVICE)

        optimizer.zero_grad()

        outputs = model(images)

        loss = criterion(
            outputs,
            labels
        )

        loss.backward()

        optimizer.step()


        running_loss += loss.item()


        _, predictions = torch.max(
            outputs,
            1
        )


        total += labels.size(0)

        correct += (
            predictions == labels
        ).sum().item()


    train_accuracy = (
        100 * correct / total
    )


    # ========================================================
    # VALIDATION
    # ========================================================

    model.eval()

    val_correct = 0
    val_total = 0


    with torch.no_grad():

        for images, labels in val_loader:

            images = images.to(DEVICE)
            labels = labels.to(DEVICE)

            outputs = model(images)


            _, predictions = torch.max(
                outputs,
                1
            )


            val_total += labels.size(0)

            val_correct += (
                predictions == labels
            ).sum().item()


    val_accuracy = (
        100
        * val_correct
        / val_total
    )


    average_loss = (
        running_loss /
        len(train_loader)
    )


    print(
        f"\nEpoch [{epoch + 1}/{EPOCHS}]"
    )

    print(
        f"Loss: "
        f"{average_loss:.4f}"
    )

    print(
        f"Training Accuracy: "
        f"{train_accuracy:.2f}%"
    )

    print(
        f"Validation Accuracy: "
        f"{val_accuracy:.2f}%"
    )


    # ========================================================
    # SAVE BEST MODEL
    # ========================================================

    if val_accuracy > best_val_accuracy:

        best_val_accuracy = val_accuracy


        checkpoint = {

            "model_state_dict":
                model.state_dict(),

            "classes":
                base_dataset.classes,

            "class_to_idx":
                base_dataset.class_to_idx,

            "image_size":
                IMAGE_SIZE,

            "validation_accuracy":
                best_val_accuracy,

            "split_method":
                "grouped_capture_split",
        }


        torch.save(
            checkpoint,

            MODEL_DIR /
            "sariwaba_mobilenetv3_best.pth"
        )


        print(
            "Best model saved! "
            f"Validation Accuracy: "
            f"{best_val_accuracy:.2f}%"
        )


# ============================================================
# TEST BEST MODEL
# ============================================================

print("\n" + "=" * 60)
print("Testing best grouped model")
print("=" * 60)


checkpoint = torch.load(

    MODEL_DIR /
    "sariwaba_mobilenetv3_best.pth",

    map_location=DEVICE,

    weights_only=False,
)


model.load_state_dict(
    checkpoint["model_state_dict"]
)


model.eval()

test_correct = 0
test_total = 0


with torch.no_grad():

    for images, labels in test_loader:

        images = images.to(DEVICE)
        labels = labels.to(DEVICE)

        outputs = model(images)

        _, predictions = torch.max(
            outputs,
            1
        )


        test_total += labels.size(0)

        test_correct += (
            predictions == labels
        ).sum().item()


test_accuracy = (
    100
    * test_correct
    / test_total
)


print(
    f"\nBest validation accuracy: "
    f"{best_val_accuracy:.2f}%"
)

print(
    f"Final test accuracy: "
    f"{test_accuracy:.2f}%"
)

print("\nTraining complete.")
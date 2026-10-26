from pathlib import Path
from collections import Counter

import torch
from torch import nn, optim
from torch.utils.data import DataLoader, Subset
from torchvision import datasets, models, transforms
from sklearn.model_selection import train_test_split


# ============================================================
# CONFIGURATION
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


DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

print("=" * 60)
print("SariwaBa Fish Freshness Training")
print("=" * 60)
print(f"Device: {DEVICE}")
print(f"Dataset: {DATA_DIR}")


# ============================================================
# IMAGE TRANSFORMS
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


print("\nDetected classes:")
print(base_dataset.classes)

print("\nClass mapping:")
print(base_dataset.class_to_idx)

print(f"\nTotal images: {len(base_dataset)}")


targets = [
    target
    for _, target in base_dataset.samples
]

class_counts = Counter(targets)

print("\nImages per class:")

for class_name, class_index in base_dataset.class_to_idx.items():
    print(
        f"{class_name}: "
        f"{class_counts[class_index]}"
    )


# ============================================================
# TRAIN / VALIDATION / TEST SPLIT
# ============================================================

all_indices = list(
    range(len(base_dataset))
)


train_indices, temp_indices = train_test_split(
    all_indices,
    test_size=0.30,
    random_state=RANDOM_SEED,
    stratify=targets,
)


temp_targets = [
    targets[index]
    for index in temp_indices
]


val_indices, test_indices = train_test_split(
    temp_indices,
    test_size=0.50,
    random_state=RANDOM_SEED,
    stratify=temp_targets,
)


print("\nDataset split:")
print(f"Training:   {len(train_indices)}")
print(f"Validation: {len(val_indices)}")
print(f"Testing:    {len(test_indices)}")


# ============================================================
# CREATE SEPARATE DATASETS WITH DIFFERENT TRANSFORMS
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


# ============================================================
# DATA LOADERS
# ============================================================

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
# LOAD MOBILENETV3 SMALL
# ============================================================

weights = models.MobileNet_V3_Small_Weights.DEFAULT

model = models.mobilenet_v3_small(
    weights=weights
)


# Freeze convolution feature extractor first.
for parameter in model.features.parameters():
    parameter.requires_grad = False


num_features = model.classifier[3].in_features

model.classifier[3] = nn.Linear(
    num_features,
    len(base_dataset.classes),
)


model = model.to(DEVICE)


# ============================================================
# LOSS + OPTIMIZER
# ============================================================

# Calculate class weights because your Fresh and NonFresh
# classes may contain different numbers of images.

train_targets = [
    targets[index]
    for index in train_indices
]

train_counts = Counter(train_targets)

number_of_classes = len(base_dataset.classes)
total_train_images = len(train_targets)


class_weights = []

for class_index in range(number_of_classes):

    count = train_counts[class_index]

    weight = (
        total_train_images /
        (number_of_classes * count)
    )

    class_weights.append(weight)


class_weights = torch.tensor(
    class_weights,
    dtype=torch.float32,
).to(DEVICE)


print("\nClass weights:")
print(class_weights)


criterion = nn.CrossEntropyLoss(
    weight=class_weights
)


optimizer = optim.Adam(
    model.classifier.parameters(),
    lr=LEARNING_RATE,
)


# ============================================================
# TRAINING
# ============================================================

best_val_accuracy = 0.0


for epoch in range(EPOCHS):

    # ------------------------
    # TRAIN
    # ------------------------

    model.train()

    running_loss = 0.0
    train_correct = 0
    train_total = 0


    for images, labels in train_loader:

        images = images.to(DEVICE)
        labels = labels.to(DEVICE)

        optimizer.zero_grad()

        outputs = model(images)

        loss = criterion(
            outputs,
            labels,
        )

        loss.backward()

        optimizer.step()

        running_loss += loss.item()

        _, predictions = torch.max(
            outputs,
            1,
        )

        train_total += labels.size(0)

        train_correct += (
            predictions == labels
        ).sum().item()


    train_accuracy = (
        100 * train_correct / train_total
    )


    # ------------------------
    # VALIDATION
    # ------------------------

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
                1,
            )

            val_total += labels.size(0)

            val_correct += (
                predictions == labels
            ).sum().item()


    val_accuracy = (
        100 * val_correct / val_total
    )


    average_loss = (
        running_loss /
        len(train_loader)
    )


    print(
        f"\nEpoch [{epoch + 1}/{EPOCHS}]"
    )

    print(
        f"Loss: {average_loss:.4f}"
    )

    print(
        f"Training Accuracy: "
        f"{train_accuracy:.2f}%"
    )

    print(
        f"Validation Accuracy: "
        f"{val_accuracy:.2f}%"
    )


    # ------------------------
    # SAVE BEST MODEL
    # ------------------------

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
        }


        model_path = (
            MODEL_DIR /
            "sariwaba_mobilenetv3_best.pth"
        )


        torch.save(
            checkpoint,
            model_path,
        )


        print(
            f"Best model saved! "
            f"Validation Accuracy: "
            f"{best_val_accuracy:.2f}%"
        )


# ============================================================
# LOAD BEST MODEL AND TEST
# ============================================================

print("\n" + "=" * 60)
print("Testing best model...")
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
            1,
        )

        test_total += labels.size(0)

        test_correct += (
            predictions == labels
        ).sum().item()


test_accuracy = (
    100 * test_correct / test_total
)


print(
    f"\nBest Validation Accuracy: "
    f"{best_val_accuracy:.2f}%"
)

print(
    f"Final Test Accuracy: "
    f"{test_accuracy:.2f}%"
)

print(
    "\nModel saved at:"
)

print(
    MODEL_DIR /
    "sariwaba_mobilenetv3_best.pth"
)

print("\nTraining complete.")
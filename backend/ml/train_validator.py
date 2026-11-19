
"""
SariwaBa Model A - Experimental Validator Training

Trains a MobileNetV3-Small classifier for:
    eye / gill / unsupported

Uses ONLY:
    datasets/metadata/validator_experimental_splits.csv

The test partition is NOT used during training or
checkpoint selection.

Does not overwrite Model B or alter dataset metadata.

Run from backend:
    python -m ml.train_validator
"""

import csv
import os
import random
from collections import Counter, defaultdict
from pathlib import Path

import numpy as np
import torch
import torch.nn as nn

from PIL import Image
from sklearn.metrics import (
    confusion_matrix,
    f1_score,
    precision_recall_fscore_support,
)
from torch.utils.data import DataLoader, Dataset
from torchvision import models, transforms


BASE_DIR = Path(__file__).resolve().parent.parent

SPLIT_CSV = (
    BASE_DIR
    / "datasets"
    / "metadata"
    / "validator_experimental_splits.csv"
)

MODEL_DIR = BASE_DIR / "ml" / "models"

CHECKPOINT = (
    MODEL_DIR / "sariwaba_validator_experimental_best.pth"
)

CLASSES = ["eye", "gill", "unsupported"]
CLASS_TO_IDX = {
    name: index for index, name in enumerate(CLASSES)
}

IMAGE_SIZE = 224
BATCH_SIZE = 16
MAX_EPOCHS = 15
PATIENCE = 5
LEARNING_RATE = 0.001
SEED = 42

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

TRAIN_TRANSFORM = transforms.Compose([
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
    transforms.RandomHorizontalFlip(p=0.5),
    transforms.RandomRotation(8),
    transforms.ColorJitter(
        brightness=0.12,
        contrast=0.12,
        saturation=0.10,
    ),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])

EVAL_TRANSFORM = transforms.Compose([
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
    transforms.ToTensor(),
    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])


class ValidatorDataset(Dataset):
    def __init__(self, rows, transform):
        self.transform = transform
        self.samples = []

        for row in rows:
            label = row["anatomical_label"]

            if label not in CLASS_TO_IDX:
                raise ValueError(
                    f"Unknown validator class: {label}"
                )

            image_path = Path(row["image_path"])

            if image_path.is_absolute():
                raise ValueError(
                    f"Absolute image path: {image_path}"
                )

            if ".." in image_path.parts:
                raise ValueError(
                    f"Unsafe image path: {image_path}"
                )

            absolute = (
                BASE_DIR / image_path
            ).resolve()

            if not absolute.is_relative_to(
                BASE_DIR.resolve()
            ):
                raise ValueError(
                    f"Image outside backend: {image_path}"
                )

            if not absolute.is_file():
                raise FileNotFoundError(
                    f"Missing image: {absolute}"
                )

            self.samples.append(
                (absolute, CLASS_TO_IDX[label])
            )

        if not self.samples:
            raise ValueError("Empty dataset partition.")

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, index):
        path, label = self.samples[index]

        with Image.open(path) as original:
            image = original.convert("RGB")

        image = self.transform(image)

        return image, label


def set_seed():
    random.seed(SEED)
    np.random.seed(SEED)
    torch.manual_seed(SEED)

    if torch.cuda.is_available():
        torch.cuda.manual_seed_all(SEED)


def load_splits():
    if not SPLIT_CSV.is_file():
        raise FileNotFoundError(
            f"Experimental split missing: {SPLIT_CSV}"
        )

    with SPLIT_CSV.open(
        "r",
        newline="",
        encoding="utf-8-sig",
    ) as file:
        reader = csv.DictReader(file)

        required = {
            "image_path",
            "anatomical_label",
            "group_key",
            "split",
            "split_status",
        }

        if not reader.fieldnames:
            raise ValueError("Split manifest has no header.")

        if not required.issubset(reader.fieldnames):
            raise ValueError(
                "Experimental split manifest is missing "
                f"columns: {sorted(required - set(reader.fieldnames))}"
            )

        rows = list(reader)

    partitions = {
        "train": [],
        "val": [],
        "test": [],
    }

    seen_paths = set()
    group_splits = defaultdict(set)

    for row in rows:
        path = row["image_path"].strip().replace("\\", "/")
        split = row["split"].strip()
        group = row["group_key"].strip()

        if split not in partitions:
            raise ValueError(
                f"Invalid partition: {split}"
            )

        if not group:
            raise ValueError(
                f"Missing group for: {path}"
            )

        if row["split_status"].strip() != (
            "experimental_unverified"
        ):
            raise ValueError(
                f"Unexpected split status for {path}"
            )

        if path in seen_paths:
            raise ValueError(
                f"Duplicate split path: {path}"
            )

        seen_paths.add(path)
        group_splits[group].add(split)

        row["image_path"] = path
        partitions[split].append(row)

    for group, assigned in group_splits.items():
        if len(assigned) > 1:
            raise ValueError(
                f"Group crosses partitions: {group}"
            )

    if len(rows) != 5911:
        raise ValueError(
            f"Expected 5911 records, found {len(rows)}."
        )

    expected = {
        "train": 4153,
        "val": 880,
        "test": 878,
    }

    for split, count in expected.items():
        if len(partitions[split]) != count:
            raise ValueError(
                f"{split}: expected {count}, "
                f"found {len(partitions[split])}"
            )

        labels = Counter(
            row["anatomical_label"]
            for row in partitions[split]
        )

        for label in CLASSES:
            if labels[label] == 0:
                raise ValueError(
                    f"{split} contains no {label} images."
                )

    return partitions


def build_model():
    weights = (
        models.MobileNet_V3_Small_Weights.DEFAULT
    )

    model = models.mobilenet_v3_small(
        weights=weights
    )

    for parameter in model.features.parameters():
        parameter.requires_grad = False

    # Keep the pretrained classifier layers frozen.
    for parameter in model.classifier.parameters():
        parameter.requires_grad = False

    input_features = model.classifier[3].in_features

    model.classifier[3] = nn.Linear(
        input_features,
        len(CLASSES),
    )

    return model


def create_class_weights(dataset):
    counts = Counter(
        label for _, label in dataset.samples
    )

    total = len(dataset)
    weights = []

    for index in range(len(CLASSES)):
        count = counts[index]

        if count == 0:
            raise ValueError(
                f"Class {CLASSES[index]} has no samples."
            )

        weights.append(
            total / (len(CLASSES) * count)
        )

    return torch.tensor(
        weights,
        dtype=torch.float32,
        device=DEVICE,
    )


def train_epoch(model, loader, criterion, optimizer):
    model.train()

    # Keep frozen feature extractor in eval mode.
    model.features.eval()

    total_loss = 0.0
    correct = 0
    total = 0

    for images, labels in loader:
        images = images.to(DEVICE)
        labels = labels.to(DEVICE)

        optimizer.zero_grad(set_to_none=True)

        outputs = model(images)
        loss = criterion(outputs, labels)

        loss.backward()
        optimizer.step()

        batch_size = labels.size(0)

        total_loss += loss.item() * batch_size

        predictions = outputs.argmax(dim=1)
        correct += (
            predictions == labels
        ).sum().item()

        total += batch_size

    return total_loss / total, correct / total


@torch.no_grad()
def evaluate(model, loader, criterion):
    model.eval()

    actual = []
    predicted = []

    total_loss = 0.0
    total = 0

    for images, labels in loader:
        images = images.to(DEVICE)
        labels = labels.to(DEVICE)

        outputs = model(images)
        loss = criterion(outputs, labels)

        batch_size = labels.size(0)

        total_loss += loss.item() * batch_size
        total += batch_size

        actual.extend(labels.cpu().tolist())
        predicted.extend(
            outputs.argmax(dim=1).cpu().tolist()
        )

    macro_f1 = f1_score(
        actual,
        predicted,
        labels=list(range(len(CLASSES))),
        average="macro",
        zero_division=0,
    )

    accuracy = (
        sum(a == b for a, b in zip(actual, predicted))
        / len(actual)
    )

    matrix = confusion_matrix(
        actual,
        predicted,
        labels=list(range(len(CLASSES))),
    )

    precision, recall, class_f1, support = (
        precision_recall_fscore_support(
            actual,
            predicted,
            labels=list(range(len(CLASSES))),
            zero_division=0,
        )
    )

    return {
        "loss": total_loss / total,
        "accuracy": accuracy,
        "macro_f1": float(macro_f1),
        "confusion_matrix": matrix,
        "precision": precision,
        "recall": recall,
        "class_f1": class_f1,
        "support": support,
    }


def main():
    print("=" * 60)
    print("SariwaBa - Model A Experimental Training")
    print("=" * 60)

    if CHECKPOINT.exists():
        raise FileExistsError(
            "Validator checkpoint already exists. "
            "Refusing to overwrite:\n"
            f"{CHECKPOINT}"
        )

    set_seed()

    partitions = load_splits()

    train_dataset = ValidatorDataset(
        partitions["train"],
        TRAIN_TRANSFORM,
    )

    val_dataset = ValidatorDataset(
        partitions["val"],
        EVAL_TRANSFORM,
    )

    # No test DataLoader is created:
    # test data must remain untouched until final
    # experimental evaluation.
    print("Device:", DEVICE)
    print("Training images:", len(train_dataset))
    print("Validation images:", len(val_dataset))
    print("Reserved test images:", len(partitions["test"]))
    print("Classes:", CLASSES)
    print()

    train_counts = Counter(
        label for _, label in train_dataset.samples
    )

    print("Training class counts:")
    for name, index in CLASS_TO_IDX.items():
        print(f"  {name}: {train_counts[index]}")

    class_weights = create_class_weights(
        train_dataset
    )

    print(
        "Class weights:",
        [round(v, 4) for v in class_weights.tolist()],
    )
    print()

    train_loader = DataLoader(
        train_dataset,
        batch_size=BATCH_SIZE,
        shuffle=True,
        num_workers=0,
    )

    val_loader = DataLoader(
        val_dataset,
        batch_size=BATCH_SIZE,
        shuffle=False,
        num_workers=0,
    )

    model = build_model().to(DEVICE)

    criterion = nn.CrossEntropyLoss(
        weight=class_weights
    )

    optimizer = torch.optim.Adam(
        model.classifier[3].parameters(),
        lr=LEARNING_RATE,
    )

    best_f1 = -1.0
    best_epoch = 0
    no_improvement = 0

    MODEL_DIR.mkdir(
        parents=True,
        exist_ok=True,
    )

    for epoch in range(1, MAX_EPOCHS + 1):
        train_loss, train_accuracy = train_epoch(
            model,
            train_loader,
            criterion,
            optimizer,
        )

        validation = evaluate(
            model,
            val_loader,
            criterion,
        )

        print(
            f"Epoch {epoch:02d}/{MAX_EPOCHS} | "
            f"Train Loss: {train_loss:.4f} | "
            f"Train Acc: {train_accuracy:.4f} | "
            f"Val Loss: {validation['loss']:.4f} | "
            f"Val Acc: {validation['accuracy']:.4f} | "
            f"Val Macro-F1: {validation['macro_f1']:.4f}",
            flush=True,
        )

        if validation["macro_f1"] > best_f1 + 1e-6:
            best_f1 = validation["macro_f1"]
            best_epoch = epoch
            no_improvement = 0

            checkpoint_data = {
                "model_name": "mobilenet_v3_small",
                "model_role": "anatomical_validator",
                "state_dict": model.state_dict(),
                "classes": CLASSES,
                "class_to_idx": CLASS_TO_IDX,
                "image_size": IMAGE_SIZE,
                "best_epoch": epoch,
                "validation_macro_f1": best_f1,
                "validation_accuracy": validation[
                    "accuracy"
                ],
                "experimental": True,
                "source_groups_verified": False,
                "split_manifest": (
                    "validator_experimental_splits.csv"
                ),
                "preprocessing": {
                    "resize": [IMAGE_SIZE, IMAGE_SIZE],
                    "mean": [0.485, 0.456, 0.406],
                    "std": [0.229, 0.224, 0.225],
                },
            }

            temporary_path = CHECKPOINT.with_suffix(
                ".tmp"
            )

            torch.save(
                checkpoint_data,
                temporary_path,
            )

            # Atomically replace the best checkpoint when
            # validation macro-F1 improves.
            os.replace(temporary_path, CHECKPOINT)

            no_improvement = 0

            print(
                f"  Saved best checkpoint: epoch {epoch}",
                flush=True,
            )

        else:
            no_improvement += 1

        if no_improvement >= PATIENCE:
            print("Early stopping triggered.")
            break

    print()
    print("=" * 60)
    print("TRAINING COMPLETE")
    print("=" * 60)
    print("Best epoch:", best_epoch)
    print("Best validation macro-F1:", round(best_f1, 4))
    print("Checkpoint:", CHECKPOINT)
    print()
    print("IMPORTANT:")
    print("- This is an experimental validator.")
    print("- Test partition was not evaluated.")
    print("- Source independence remains unverified.")
    print("- Wrong-region negatives are absent from val/test.")
    print("- Model B checkpoint was not modified.")
    print("- Do not deploy Model A before evaluation.")


if __name__ == "__main__":
    main()

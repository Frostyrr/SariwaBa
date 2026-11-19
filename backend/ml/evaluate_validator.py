
"""
SariwaBa Model A - Experimental Test Evaluation

Evaluates the existing best Model A checkpoint using
the reserved test partition only.

Does NOT:
- Train or update the model
- Change images or metadata
- Modify Model B
- Save new checkpoints

Run from backend:
    python -m ml.evaluate_validator

Results are exploratory because the original image
source/specimen identities remain unverified.
"""

import csv
from collections import Counter, defaultdict
from pathlib import Path

import torch
import torch.nn as nn

from PIL import Image
from sklearn.metrics import (
    accuracy_score,
    classification_report,
    confusion_matrix,
    f1_score,
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

CHECKPOINT = (
    BASE_DIR
    / "ml"
    / "models"
    / "sariwaba_validator_experimental_best.pth"
)

CLASSES = ["eye", "gill", "unsupported"]
CLASS_TO_IDX = {
    name: index for index, name in enumerate(CLASSES)
}

IMAGE_SIZE = 224
BATCH_SIZE = 16
DEVICE = torch.device("cpu")


class TestDataset(Dataset):
    def __init__(self, records):
        self.samples = []

        self.transform = transforms.Compose([
            transforms.Resize(
                (IMAGE_SIZE, IMAGE_SIZE)
            ),
            transforms.ToTensor(),
            transforms.Normalize(
                mean=[0.485, 0.456, 0.406],
                std=[0.229, 0.224, 0.225],
            ),
        ])

        root = BASE_DIR.resolve()

        for row in records:
            label = row["anatomical_label"].strip()

            if label not in CLASS_TO_IDX:
                raise ValueError(
                    f"Unknown label: {label}"
                )

            relative = Path(row["image_path"])

            if (
                relative.is_absolute()
                or ".." in relative.parts
            ):
                raise ValueError(
                    f"Unsafe image path: {relative}"
                )

            full_path = (root / relative).resolve()

            if not full_path.is_relative_to(root):
                raise ValueError(
                    f"Path escapes project: {relative}"
                )

            if not full_path.is_file():
                raise FileNotFoundError(full_path)

            self.samples.append({
                "path": full_path,
                "label": CLASS_TO_IDX[label],
                "category": row.get(
                    "negative_category", ""
                ).strip(),
            })

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, index):
        record = self.samples[index]

        with Image.open(record["path"]) as image:
            rgb_image = image.convert("RGB")

        tensor = self.transform(rgb_image)

        return (
            tensor,
            record["label"],
            index,
        )


def load_test_records():
    if not SPLIT_CSV.is_file():
        raise FileNotFoundError(SPLIT_CSV)

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
            "negative_category",
        }

        if not reader.fieldnames:
            raise ValueError("Missing CSV header.")

        missing = required - set(reader.fieldnames)

        if missing:
            raise ValueError(
                f"Missing columns: {sorted(missing)}"
            )

        rows = list(reader)

    partitions = defaultdict(list)
    groups = defaultdict(set)
    paths = set()

    for row in rows:
        path = row["image_path"].strip()
        partition = row["split"].strip()
        group = row["group_key"].strip()

        if not path or path in paths:
            raise ValueError(
                f"Empty or duplicate path: {path}"
            )

        paths.add(path)

        if partition not in {"train", "val", "test"}:
            raise ValueError(
                f"Invalid partition: {partition}"
            )

        if not group:
            raise ValueError(
                f"Missing group: {path}"
            )

        if (
            row["split_status"].strip()
            != "experimental_unverified"
        ):
            raise ValueError(
                f"Unexpected split status: {path}"
            )

        partitions[partition].append(row)
        groups[group].add(partition)

    for group, assigned in groups.items():
        if len(assigned) > 1:
            raise ValueError(
                f"Provisional group crosses splits: {group}"
            )

    expected = {
        "train": 4153,
        "val": 880,
        "test": 878,
    }

    for partition, count in expected.items():
        if len(partitions[partition]) != count:
            raise ValueError(
                f"{partition} expected {count}, "
                f"found {len(partitions[partition])}"
            )

    return partitions["test"]


def load_model():
    if not CHECKPOINT.is_file():
        raise FileNotFoundError(CHECKPOINT)

    # Load only the checkpoint created by our own
    # trusted local training script.
    checkpoint = torch.load(
        CHECKPOINT,
        map_location=DEVICE,
        weights_only=True,
    )

    if checkpoint.get("classes") != CLASSES:
        raise ValueError(
            "Checkpoint classes do not match."
        )

    if checkpoint.get("class_to_idx") != CLASS_TO_IDX:
        raise ValueError(
            "Checkpoint label mapping mismatch."
        )

    if checkpoint.get("image_size") != IMAGE_SIZE:
        raise ValueError(
            "Checkpoint input size mismatch."
        )

    if checkpoint.get("experimental") is not True:
        raise ValueError(
            "Expected experimental checkpoint."
        )

    model = models.mobilenet_v3_small(
        weights=None
    )

    input_features = model.classifier[3].in_features

    model.classifier[3] = nn.Linear(
        input_features,
        len(CLASSES),
    )

    model.load_state_dict(
        checkpoint["state_dict"],
        strict=True,
    )

    model.to(DEVICE)
    model.eval()

    return model, checkpoint


def print_matrix(matrix):
    print()
    print("CONFUSION MATRIX")
    print("Rows = actual; columns = predicted")
    print("-" * 60)

    print(
        f"{'Actual':<15}"
        + "".join(f"{name:>14}" for name in CLASSES)
    )

    for name, values in zip(CLASSES, matrix):
        print(
            f"{name:<15}"
            + "".join(f"{value:>14}" for value in values)
        )


@torch.inference_mode()
def main():
    print("=" * 60)
    print("SariwaBa Model A - Experimental Test Evaluation")
    print("=" * 60)

    test_records = load_test_records()

    dataset = TestDataset(test_records)

    loader = DataLoader(
        dataset,
        batch_size=BATCH_SIZE,
        shuffle=False,
        num_workers=0,
    )

    model, checkpoint = load_model()

    actual = []
    predicted = []
    results = []

    print("Device:", DEVICE)
    print("Test images:", len(dataset))
    print("Checkpoint epoch:", checkpoint["best_epoch"])
    print(
        "Checkpoint validation macro-F1:",
        round(checkpoint["validation_macro_f1"], 4),
    )

    for images, labels, indices in loader:
        images = images.to(DEVICE)

        logits = model(images)
        probabilities = torch.softmax(logits, dim=1)
        predictions = probabilities.argmax(dim=1)

        for label, prediction, index, probs in zip(
            labels.tolist(),
            predictions.cpu().tolist(),
            indices.tolist(),
            probabilities.cpu().tolist(),
        ):
            record = dataset.samples[index]

            actual.append(label)
            predicted.append(prediction)

            results.append({
                "path": record["path"],
                "actual": label,
                "predicted": prediction,
                "category": record["category"],
                "confidence": max(probs),
            })

    labels = list(range(len(CLASSES)))

    accuracy = accuracy_score(actual, predicted)

    macro_f1 = f1_score(
        actual,
        predicted,
        labels=labels,
        average="macro",
        zero_division=0,
    )

    print()
    print("OVERALL TEST METRICS")
    print("-" * 60)

    print(f"Accuracy: {accuracy:.4f}")
    print(f"Macro-F1: {macro_f1:.4f}")

    print()
    print("PER-CLASS PERFORMANCE")
    print("-" * 60)

    print(
        classification_report(
            actual,
            predicted,
            labels=labels,
            target_names=CLASSES,
            digits=4,
            zero_division=0,
        )
    )

    matrix = confusion_matrix(
        actual,
        predicted,
        labels=labels,
    )

    print_matrix(matrix)

    unsupported_id = CLASS_TO_IDX["unsupported"]

    unsupported = [
        record for record in results
        if record["actual"] == unsupported_id
    ]

    false_accepted = [
        record for record in unsupported
        if record["predicted"] != unsupported_id
    ]

    supported = [
        record for record in results
        if record["actual"] != unsupported_id
    ]

    false_rejected = [
        record for record in supported
        if record["predicted"] == unsupported_id
    ]

    print()
    print("VALIDATOR ACCEPTANCE / REJECTION")
    print("-" * 60)

    print("Unsupported test images:", len(unsupported))
    print("Incorrectly accepted:", len(false_accepted))

    if unsupported:
        print(
            "Unsupported false-accept rate:",
            f"{100 * len(false_accepted) / len(unsupported):.2f}%",
        )

    print("Supported test images:", len(supported))
    print("Incorrectly rejected:", len(false_rejected))

    if supported:
        print(
            "Supported false-reject rate:",
            f"{100 * len(false_rejected) / len(supported):.2f}%",
        )

    print()
    print("UNSUPPORTED CATEGORY BREAKDOWN")
    print("-" * 60)

    categories = sorted({
        record["category"]
        for record in unsupported
    })

    for category in categories:
        items = [
            item for item in unsupported
            if item["category"] == category
        ]

        accepted = sum(
            item["predicted"] != unsupported_id
            for item in items
        )

        print(
            f"{category}: {len(items)} images, "
            f"{accepted} incorrectly accepted"
        )

    if "wrong_fish_regions" not in categories:
        print(
            "WARNING: No wrong_fish_regions "
            "examples in the test partition."
        )

    mistakes = [
        item for item in results
        if item["actual"] != item["predicted"]
    ]

    mistakes.sort(
        key=lambda item: -item["confidence"]
    )

    print()
    print("TOP 15 HIGH-CONFIDENCE ERRORS")
    print("-" * 60)

    for item in mistakes[:15]:
        print(
            f"{item['path'].relative_to(BASE_DIR)}"
            f" | actual={CLASSES[item['actual']]}"
            f" | predicted={CLASSES[item['predicted']]}"
            f" | confidence={item['confidence']:.4f}"
        )

    print()
    print("EVALUATION COMPLETE")
    print("-" * 60)
    print("No files were modified.")
    print("Test results are exploratory, not final.")
    print("Source independence is unverified.")
    print("No confidence rejection threshold was calibrated.")
    print("Model B was not modified.")


if __name__ == "__main__":
    main()

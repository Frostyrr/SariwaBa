
"""
SariwaBa shared dataset loader.

Reads CSV metadata without copying, moving, or modifying images.

Model A: eye / gill / unsupported
Model B: Fresh / NonFresh

Split filtering is strict. Unassigned records cannot be used
as a named training, validation, or test partition.
"""

import csv
from pathlib import Path

from PIL import Image
from torch.utils.data import Dataset


BASE_DIR = Path(__file__).resolve().parent.parent
METADATA_DIR = BASE_DIR / "datasets" / "metadata"

CLASS_MAPPINGS = {
    "validator": {
        "eye": 0,
        "gill": 1,
        "unsupported": 2,
    },
    "freshness": {
        "Fresh": 0,
        "NonFresh": 1,
    },
}

MANIFEST_FILES = {
    "validator": "validator_labels.csv",
    "freshness": "freshness_labels.csv",
}

LABEL_FIELDS = {
    "validator": "anatomical_label",
    "freshness": "freshness_label",
}

VALID_SPLITS = {"train", "val", "test"}


def read_csv(path):
    if not path.is_file():
        raise FileNotFoundError(
            f"Required metadata file not found: {path}"
        )

    with path.open(
        "r",
        newline="",
        encoding="utf-8-sig",
    ) as file:
        return list(csv.DictReader(file))


class SariwaBaSharedDataset(Dataset):
    def __init__(
        self,
        model_type,
        split=None,
        transform=None,
        metadata_dir=None,
    ):
        if model_type not in CLASS_MAPPINGS:
            raise ValueError(
                "model_type must be 'validator' or 'freshness'."
            )

        if split is not None and split not in VALID_SPLITS:
            raise ValueError(
                "split must be 'train', 'val', 'test', or None."
            )

        self.model_type = model_type
        self.transform = transform
        self.class_to_idx = CLASS_MAPPINGS[
            model_type
        ].copy()

        self.classes = list(self.class_to_idx.keys())

        self.metadata_dir = Path(
            metadata_dir
            if metadata_dir is not None
            else METADATA_DIR
        )

        manifest_path = (
            self.metadata_dir
            / MANIFEST_FILES[model_type]
        )

        records = read_csv(manifest_path)

        if split is not None:
            split_path = self.metadata_dir / "splits.csv"
            split_records = read_csv(split_path)

            split_lookup = {}

            for row in split_records:
                image_path = row["image_path"]
                assignment = row["split"].strip()

                if image_path in split_lookup:
                    raise ValueError(
                        f"Duplicate split record: {image_path}"
                    )

                if (
                    assignment
                    and assignment not in VALID_SPLITS
                ):
                    raise ValueError(
                        f"Invalid split: {assignment}"
                    )

                split_lookup[image_path] = assignment

            # Fail rather than silently train on incomplete
            # or unassigned split metadata.
            for row in records:
                image_path = row["image_path"]

                if image_path not in split_lookup:
                    raise ValueError(
                        f"Missing split record: {image_path}"
                    )

                if not split_lookup[image_path]:
                    raise ValueError(
                        "Unassigned splits detected. "
                        "Verify specimen/capture groups "
                        "and assign partitions before training."
                    )

            records = [
                row for row in records
                if split_lookup[row["image_path"]] == split
            ]

        self.samples = []
        seen_paths = set()
        label_field = LABEL_FIELDS[model_type]

        for row in records:
            image_path = row["image_path"]
            label = row[label_field]

            if image_path in seen_paths:
                raise ValueError(
                    f"Duplicate image record: {image_path}"
                )

            seen_paths.add(image_path)

            if label not in self.class_to_idx:
                raise ValueError(
                    f"Unknown {model_type} label: {label}"
                )

            relative = Path(image_path)

            if relative.is_absolute() or ".." in relative.parts:
                raise ValueError(
                    f"Unsafe image path: {image_path}"
                )

            full_path = (
                BASE_DIR / relative
            ).resolve()

            if not full_path.is_relative_to(BASE_DIR.resolve()):
                raise ValueError(
                    f"Image outside project directory: {image_path}"
                )

            if not full_path.is_file():
                raise FileNotFoundError(
                    f"Image missing: {full_path}"
                )

            self.samples.append(
                (
                    full_path,
                    self.class_to_idx[label],
                )
            )

        if not self.samples:
            raise ValueError(
                f"No samples found for {model_type}, "
                f"split={split}."
            )

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, index):
        image_path, label = self.samples[index]

        with Image.open(image_path) as source:
            image = source.convert("RGB")

        if self.transform is not None:
            image = self.transform(image)

        return image, label

    def class_counts(self):
        counts = {
            name: 0 for name in self.classes
        }

        for _, label in self.samples:
            counts[self.classes[label]] += 1

        return counts

"""Load reviewed whole-fish photos and their fish/eye annotations."""

import hashlib
import json
import math
from pathlib import Path

import torch
from PIL import Image, ImageOps
from torch.utils.data import Dataset
from torchvision.transforms.functional import to_tensor

CLASSES = ("background", "fish", "eye")
SPLITS = ("train", "val", "test")


def open_photo(path):
    with Image.open(path) as raw:
        return ImageOps.exif_transpose(raw).convert("RGB")


def check_box(box, size):
    if not isinstance(box, list) or len(box) != 4 or any(
        type(value) not in (float, int) or not math.isfinite(value) for value in box
    ):
        raise ValueError("Expected four finite box coordinates.")
    x1, y1, x2, y2 = box
    if not (0 <= x1 < x2 <= size[0] and 0 <= y1 < y2 <= size[1]):
        raise ValueError(f"Box {box} is outside the oriented image or has zero area.")
    return box


def load_partitions(manifest):
    manifest = Path(manifest).resolve()
    rows = json.loads(manifest.read_text(encoding="utf-8-sig"))
    if not isinstance(rows, list) or not rows:
        raise ValueError("The manifest must contain a nonempty JSON array.")
    partitions = {split: [] for split in SPLITS}
    assignments = {}
    seen_paths = set()
    for row in rows:
        relative = Path(row["image"])
        path = (manifest.parent / relative).resolve()
        if relative.is_absolute() or not path.is_relative_to(manifest.parent):
            raise ValueError(f"Invalid photo path: {relative}")
        if path in seen_paths:
            raise ValueError(f"Duplicate photo path: {relative}")
        seen_paths.add(path)
        split = row["split"]
        if split not in partitions:
            raise ValueError(f"Invalid split for {relative}: {split}")
        size = open_photo(path).size
        targets = []
        group_keys = [("session", row["session_id"])]
        for fish in row["fish"]:
            box = check_box(fish["box"], size)
            group_keys.append(("specimen", fish["specimen_id"]))
            eyes = []
            for item in fish["eyes"]:
                eye = check_box(item, size)
                if not (box[0] <= eye[0] < eye[2] <= box[2] and
                        box[1] <= eye[1] < eye[3] <= box[3]):
                    raise ValueError(f"Eye box must be inside its fish box: {relative}")
                eyes.append(eye)
            targets.append((box, eyes))
        group_keys.append(("sha256", hashlib.sha256(path.read_bytes()).hexdigest()))
        for kind, value in group_keys:
            if not isinstance(value, str) or not value.strip() or value != value.strip():
                raise ValueError(f"{relative} needs a valid {kind} identifier.")
            if assignments.setdefault((kind, value), split) != split:
                raise ValueError(f"{kind} {value} crosses partitions.")
        partitions[split].append((path, targets))
    for split, entries in partitions.items():
        if not any(eyes for _, fish in entries for _, eyes in fish):
            raise ValueError(f"{split} needs at least one annotated visible eye.")
    return partitions


class EyeDetectionDataset(Dataset):
    def __init__(self, entries):
        self.entries = entries

    def __len__(self):
        return len(self.entries)

    def __getitem__(self, index):
        path, fish = self.entries[index]
        boxes, labels = [], []
        for box, eyes in fish:
            boxes.append(box)
            labels.append(1)
            boxes.extend(eyes)
            labels.extend([2] * len(eyes))
        return to_tensor(open_photo(path)), {
            "boxes": torch.tensor(boxes, dtype=torch.float32).reshape(-1, 4),
            "labels": torch.tensor(labels, dtype=torch.int64),
        }

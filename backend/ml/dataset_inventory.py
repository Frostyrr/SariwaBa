"""Read-only inventory of the original Tilapia and unsupported image folders.

Kept separate from the append-only metadata updater and experimental preparation.
"""

from pathlib import Path
from collections import Counter
import re

BASE_DIR = Path(__file__).resolve().parent.parent

DATASETS_DIR = BASE_DIR / "datasets"
TILAPIA_DIR = DATASETS_DIR / "tilapia"
UNSUPPORTED_DIR = DATASETS_DIR / "unsupported"
VALID_EXTENSIONS = {".jpg", ".jpeg", ".png"}
BLOCK_SIZE = 50


def list_images(folder):
    if not folder.exists():
        return []

    return sorted(
        (
            path for path in folder.rglob("*")
            if path.is_file()
            and path.suffix.lower() in VALID_EXTENSIONS
        ),
        key=lambda path: path.as_posix().lower(),
    )


def relative_path(path):
    return path.relative_to(BASE_DIR).as_posix()


def get_tilapia_labels(path):
    parts = path.relative_to(TILAPIA_DIR).parts

    if len(parts) < 4:
        raise ValueError(f"Unexpected directory structure: {path}")

    freshness = parts[0]
    region_folder = parts[2]

    if freshness not in {"Fresh", "NonFresh"}:
        raise ValueError(f"Unknown freshness label: {path}")

    if region_folder not in {"Eyes", "Gills"}:
        raise ValueError(f"Unknown anatomical region: {path}")

    region = "eye" if region_folder == "Eyes" else "gill"

    parent = path.parent.relative_to(TILAPIA_DIR).as_posix()

    if freshness == "Fresh":
        # Preserve existing grouped-training convention.
        group_key = f"Fresh::{parent}"
        group_basis = "fresh_leaf_folder"
    else:
        # Match train_grouped.py's existing block rule.
        match = re.match(r"(\d+)", path.stem)

        number = int(match.group(1)) if match else 0
        block = number // BLOCK_SIZE

        group_key = f"NonFresh::{parent}::block_{block}"
        group_basis = (
            "nonfresh_50_frame_block"
            if match else "nonfresh_missing_number"
        )

    return freshness, region, group_key, group_basis


def prepare_records():
    freshness_rows = []
    validator_rows = []
    split_rows = []
    summary = Counter()

    for path in list_images(TILAPIA_DIR):
        freshness, region, group, group_basis = (
            get_tilapia_labels(path)
        )

        image_path = relative_path(path)

        freshness_rows.append({
            "image_path": image_path,
            "freshness_label": freshness,
            "anatomical_label": region,
            "group_key": group,
            "specimen_id": "",
        })

        validator_rows.append({
            "image_path": image_path,
            "anatomical_label": region,
            "freshness_label": freshness,
            "negative_category": "",
            "group_key": group,
            "specimen_id": "",
        })

        split_rows.append({
            "image_path": image_path,
            "group_key": group,
            "group_basis": group_basis,
            "specimen_id": "",
            "split": "",
            "split_status": "unassigned",
        })

        summary[(freshness, region)] += 1

    for path in list_images(UNSUPPORTED_DIR):
        image_path = relative_path(path)

        parts = path.relative_to(UNSUPPORTED_DIR).parts

        category = (
            parts[0] if len(parts) > 1 else "uncategorized"
        )

        # Provisional grouping only; not a specimen ID.
        parent = path.parent.relative_to(
            UNSUPPORTED_DIR
        ).as_posix()

        group = f"Unsupported::{parent}"

        validator_rows.append({
            "image_path": image_path,
            "anatomical_label": "unsupported",
            "freshness_label": "",
            "negative_category": category,
            "group_key": group,
            "specimen_id": "",
        })

        split_rows.append({
            "image_path": image_path,
            "group_key": group,
            "group_basis": "unsupported_source_folder",
            "specimen_id": "",
            "split": "",
            "split_status": "unassigned",
        })

        summary[("Unsupported", category)] += 1

    return freshness_rows, validator_rows, split_rows, summary


"""
SariwaBa Model A - Eye/Gill Dataset Diversity Audit

Generates representative contact sheets from existing
experimental train/validation/test partitions.

Purpose:
    Visually review eye/gill diversity before improving
    the anatomical validator.

Run from backend:
    python -m ml.audit_validator_diversity

Safety:
    - Does not modify original dataset images
    - Does not modify any existing CSV manifests
    - Does not train or modify either model
    - Does not use challenge images
    - Refuses to overwrite previous audit outputs

Limitations:
    - Source groups are provisional, not verified fish IDs
    - Sampling is deterministic but not statistically random
    - Visual review is required to assess diversity
"""

import csv
import math
from collections import Counter, defaultdict
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


BASE_DIR = Path(__file__).resolve().parent.parent

SPLIT_CSV = (
    BASE_DIR
    / "datasets"
    / "metadata"
    / "validator_experimental_splits.csv"
)

OUTPUT_DIR = (
    BASE_DIR
    / "ml"
    / "results"
    / "validator_diversity_audit"
)

CLASSES = ("eye", "gill")
PARTITIONS = ("train", "val", "test")

SAMPLES_PER_SHEET = 20

COLUMNS = 5
ROWS = 4

CELL_WIDTH = 235
CELL_HEIGHT = 235

THUMBNAIL_WIDTH = 210
THUMBNAIL_HEIGHT = 170

BACKGROUND = (240, 242, 245)
CARD_BACKGROUND = (255, 255, 255)
TEXT_COLOR = (30, 35, 40)
BORDER_COLOR = (190, 195, 200)

IMAGE_EXTENSIONS = {
    ".jpg",
    ".jpeg",
    ".png",
}


def load_font(size):
    candidates = [
        "arial.ttf",
        "DejaVuSans.ttf",
    ]

    for candidate in candidates:
        try:
            return ImageFont.truetype(
                candidate,
                size,
            )
        except OSError:
            continue

    return ImageFont.load_default()


def load_manifest():
    if not SPLIT_CSV.is_file():
        raise FileNotFoundError(
            f"Split manifest missing: {SPLIT_CSV}"
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
        }

        if not reader.fieldnames:
            raise ValueError(
                "Split manifest is missing its header."
            )

        missing = required - set(reader.fieldnames)

        if missing:
            raise ValueError(
                f"Missing CSV columns: {sorted(missing)}"
            )

        records = list(reader)

    seen = set()
    grouped = defaultdict(list)
    group_splits = defaultdict(set)

    for row in records:
        path_text = row["image_path"].strip().replace(
            "\\", "/"
        )

        label = row["anatomical_label"].strip()
        partition = row["split"].strip()
        group_key = row["group_key"].strip()

        if not path_text or path_text in seen:
            raise ValueError(
                f"Empty or duplicate image path: {path_text}"
            )

        seen.add(path_text)

        if not group_key:
            raise ValueError(
                f"Missing group key for {path_text}"
            )

        if partition not in PARTITIONS:
            raise ValueError(
                f"Invalid partition: {partition}"
            )

        group_splits[group_key].add(partition)

        if label not in CLASSES:
            continue

        relative = Path(path_text)

        if (
            relative.is_absolute()
            or ".." in relative.parts
        ):
            raise ValueError(
                f"Unsafe image path: {path_text}"
            )

        full_path = (
            BASE_DIR / relative
        ).resolve()

        if not full_path.is_relative_to(
            BASE_DIR.resolve()
        ):
            raise ValueError(
                f"Image outside backend: {path_text}"
            )

        if not full_path.is_file():
            raise FileNotFoundError(
                f"Image missing: {full_path}"
            )

        if full_path.suffix.lower() not in (
            IMAGE_EXTENSIONS
        ):
            raise ValueError(
                f"Unsupported image extension: {full_path}"
            )

        grouped[(label, partition, group_key)].append({
            "image_path": path_text,
            "absolute_path": full_path,
            "label": label,
            "partition": partition,
            "group_key": group_key,
        })

    leaking_groups = [
        key
        for key, partitions in group_splits.items()
        if len(partitions) > 1
    ]

    if leaking_groups:
        raise ValueError(
            "Provisional group crosses partitions: "
            + ", ".join(leaking_groups[:10])
        )

    return grouped


def select_representative_samples(
    grouped,
    label,
    partition,
    maximum,
):
    """
    Select from as many different provisional groups
    as possible using deterministic round-robin sampling.
    """

    by_group = {}

    for (
        record_label,
        record_partition,
        group_key,
    ), items in grouped.items():
        if (
            record_label == label
            and record_partition == partition
        ):
            by_group[group_key] = sorted(
                items,
                key=lambda item: item["image_path"],
            )

    if not by_group:
        return [], 0

    # Start with the largest groups while ensuring
    # smaller groups can also contribute a sample.
    ordered_groups = sorted(
        by_group,
        key=lambda key: (
            -len(by_group[key]),
            key,
        ),
    )

    # Spread selections across each group's filename
    # ordering instead of taking only the first frames.
    for key in ordered_groups:
        items = by_group[key]
        reordered = []

        left = 0
        right = len(items) - 1

        while left <= right:
            reordered.append(items[left])
            left += 1

            if left <= right:
                reordered.append(items[right])
                right -= 1

        by_group[key] = reordered

    selected = []
    position = 0

    while len(selected) < maximum:
        added = False

        for key in ordered_groups:
            items = by_group[key]

            if position < len(items):
                selected.append(items[position])
                added = True

                if len(selected) >= maximum:
                    break

        if not added:
            break

        position += 1

    return selected, len(ordered_groups)


def make_contact_sheet(
    samples,
    label,
    partition,
):
    canvas = Image.new(
        "RGB",
        (
            CELL_WIDTH * COLUMNS,
            CELL_HEIGHT * ROWS,
        ),
        BACKGROUND,
    )

    draw = ImageDraw.Draw(canvas)
    font = load_font(13)
    small_font = load_font(10)

    errors = []

    for index, item in enumerate(samples):
        column = index % COLUMNS
        row = index // COLUMNS

        x = column * CELL_WIDTH
        y = row * CELL_HEIGHT

        draw.rectangle(
            (
                x + 3,
                y + 3,
                x + CELL_WIDTH - 4,
                y + CELL_HEIGHT - 4,
            ),
            fill=CARD_BACKGROUND,
            outline=BORDER_COLOR,
            width=1,
        )

        try:
            with Image.open(
                item["absolute_path"]
            ) as source:
                original_size = source.size

                thumbnail = source.convert("RGB")

                thumbnail.thumbnail(
                    (
                        THUMBNAIL_WIDTH,
                        THUMBNAIL_HEIGHT,
                    ),
                    Image.Resampling.LANCZOS,
                )

            image_x = (
                x + (CELL_WIDTH - thumbnail.width) // 2
            )

            image_y = y + 9

            canvas.paste(
                thumbnail,
                (image_x, image_y),
            )

            dimensions = (
                f"{original_size[0]}x{original_size[1]}"
            )

        except Exception as exc:
            dimensions = "Unreadable"
            errors.append(
                (item["image_path"], str(exc))
            )

            draw.text(
                (x + 12, y + 85),
                "IMAGE ERROR",
                fill=(180, 20, 20),
                font=font,
            )

        filename = Path(
            item["image_path"]
        ).name

        filename = filename[:27]

        group_name = (
            item["group_key"].split("::")[-1]
        )[:30]

        draw.text(
            (x + 10, y + 183),
            filename,
            fill=TEXT_COLOR,
            font=font,
        )

        draw.text(
            (x + 10, y + 202),
            dimensions,
            fill=(85, 90, 95),
            font=small_font,
        )

        draw.text(
            (x + 10, y + 216),
            group_name,
            fill=(85, 90, 95),
            font=small_font,
        )

    output_path = (
        OUTPUT_DIR
        / f"{label}_{partition}_review.png"
    )

    if output_path.exists():
        raise FileExistsError(
            f"Review sheet already exists: {output_path}"
        )

    canvas.save(
        output_path,
        format="PNG",
    )

    return output_path, errors


def main():
    print("=" * 65)
    print("SariwaBa Model A - Eye/Gill Diversity Audit")
    print("=" * 65)

    # Prevent accidental overwriting of earlier reviews.
    if OUTPUT_DIR.exists():
        raise FileExistsError(
            "Audit output directory already exists. "
            "Preserving previous work:\n"
            f"{OUTPUT_DIR}"
        )

    grouped = load_manifest()

    selections = {}
    summary_rows = []
    all_errors = []

    for label in CLASSES:
        for partition in PARTITIONS:
            samples, group_count = (
                select_representative_samples(
                    grouped,
                    label,
                    partition,
                    SAMPLES_PER_SHEET,
                )
            )

            if not samples:
                raise ValueError(
                    f"No samples for {label}/{partition}"
                )

            selections[(label, partition)] = samples

            available_count = sum(
                len(items)
                for (
                    record_label,
                    record_partition,
                    _,
                ), items in grouped.items()
                if (
                    record_label == label
                    and record_partition == partition
                )
            )

            summary_rows.append({
                "class": label,
                "split": partition,
                "available_images": available_count,
                "available_groups": group_count,
                "sampled_images": len(samples),
                "sampled_groups": len({
                    item["group_key"]
                    for item in samples
                }),
            })

    # Create one output directory after validating
    # the full manifest and all selections.
    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=False,
    )

    print()
    print("CONTACT SHEETS")
    print("-" * 65)

    for label in CLASSES:
        for partition in PARTITIONS:
            samples = selections[(label, partition)]

            output_path, errors = make_contact_sheet(
                samples,
                label,
                partition,
            )

            all_errors.extend(errors)

            print(
                f"{label.upper():<5} "
                f"{partition:<5}: "
                f"{len(samples)} samples -> "
                f"{output_path.name}"
            )

    summary_path = OUTPUT_DIR / "audit_summary.csv"

    with summary_path.open(
        "x",
        newline="",
        encoding="utf-8",
    ) as file:
        writer = csv.DictWriter(
            file,
            fieldnames=[
                "class",
                "split",
                "available_images",
                "available_groups",
                "sampled_images",
                "sampled_groups",
            ],
        )

        writer.writeheader()
        writer.writerows(summary_rows)

    selections_path = (
        OUTPUT_DIR / "selected_images.csv"
    )

    with selections_path.open(
        "x",
        newline="",
        encoding="utf-8",
    ) as file:
        writer = csv.DictWriter(
            file,
            fieldnames=[
                "image_path",
                "anatomical_label",
                "split",
                "group_key",
            ],
        )

        writer.writeheader()

        for (label, partition), samples in (
            selections.items()
        ):
            for item in samples:
                writer.writerow({
                    "image_path": item["image_path"],
                    "anatomical_label": label,
                    "split": partition,
                    "group_key": item["group_key"],
                })

    print()
    print("DATASET REPRESENTATION")
    print("-" * 65)

    for row in summary_rows:
        print(
            f"{row['class']:<5} "
            f"{row['split']:<5}: "
            f"{row['available_images']} images, "
            f"{row['available_groups']} groups, "
            f"{row['sampled_images']} sampled from "
            f"{row['sampled_groups']} groups"
        )

    print()
    print("Unreadable images:", len(all_errors))

    for path, error in all_errors:
        print("  ERROR:", path, error)

    print()
    print("Output directory:")
    print(OUTPUT_DIR)

    print()
    print("IMPORTANT:")
    print("- Six contact sheets were generated.")
    print("- Original images were not modified.")
    print("- Original metadata was not modified.")
    print("- Existing model checkpoints remain unchanged.")
    print("- Provisional groups are not verified specimens.")
    print("- Contact sheets require visual interpretation.")
    print("- No ML training was performed.")


if __name__ == "__main__":
    main()

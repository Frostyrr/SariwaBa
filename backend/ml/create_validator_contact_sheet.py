
"""
SariwaBa Model A - Rohu Dataset Contact Sheet Generator

Creates labeled contact sheets for reviewing Rohu images
before source-aware dataset splitting.

Run from backend:
    python -m ml.create_validator_contact_sheet
    python -m ml.create_validator_contact_sheet --dataset v2

Original images, metadata, and model files remain unchanged.
"""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
import math
import argparse


BASE_DIR = Path(__file__).resolve().parent.parent

SOURCE_DIR = (
    BASE_DIR
    / "datasets"
    / "unsupported"
    / "other_fish_species"
)

OUTPUT_DIR = (
    BASE_DIR
    / "ml"
    / "results"
    / "validator_review"
)

FILENAME_PREFIX = "rohu"

SUPPORTED_EXTENSIONS = {
    ".jpg",
    ".jpeg",
    ".png",
}

COLUMNS = 5
ROWS = 5

CELL_WIDTH = 220
CELL_HEIGHT = 210

IMAGE_WIDTH = 200
IMAGE_HEIGHT = 165

MARGIN = 12
LABEL_HEIGHT = 25

BACKGROUND = (245, 245, 245)
CELL_BACKGROUND = (255, 255, 255)
TEXT_COLOR = (20, 20, 20)
BORDER_COLOR = (190, 190, 190)


def get_font():
    possible_fonts = [
        "arial.ttf",
        "DejaVuSans.ttf",
    ]

    for font_name in possible_fonts:
        try:
            return ImageFont.truetype(
                font_name,
                14,
            )
        except OSError:
            continue

    return ImageFont.load_default()


def collect_images(source_dir=SOURCE_DIR, filename_prefix=FILENAME_PREFIX):
    if not source_dir.is_dir():
        raise FileNotFoundError(
            f"Dataset directory not found: {source_dir}"
        )

    images = [
        path
        for path in source_dir.rglob("*")
        if path.is_file()
        and path.suffix.lower() in SUPPORTED_EXTENSIONS
        and path.name.lower().startswith(filename_prefix)
    ]

    return sorted(
        images,
        key=lambda path: path.as_posix().lower(),
    )


def prepare_thumbnail(image_path):
    with Image.open(image_path) as source:
        image = source.convert("RGB")

    image.thumbnail(
        (IMAGE_WIDTH, IMAGE_HEIGHT),
        Image.Resampling.LANCZOS,
    )

    return image


def create_contact_sheet(image_paths, page_number, font,
                         output_dir=OUTPUT_DIR, output_prefix="rohu"):
    sheet_width = COLUMNS * CELL_WIDTH
    sheet_height = ROWS * CELL_HEIGHT

    sheet = Image.new(
        "RGB",
        (sheet_width, sheet_height),
        BACKGROUND,
    )

    draw = ImageDraw.Draw(sheet)
    errors = []

    for index, image_path in enumerate(image_paths):
        row = index // COLUMNS
        column = index % COLUMNS

        x = column * CELL_WIDTH
        y = row * CELL_HEIGHT

        draw.rectangle(
            (
                x + 3,
                y + 3,
                x + CELL_WIDTH - 4,
                y + CELL_HEIGHT - 4,
            ),
            fill=CELL_BACKGROUND,
            outline=BORDER_COLOR,
            width=1,
        )

        try:
            thumbnail = prepare_thumbnail(image_path)

            image_x = (
                x + (CELL_WIDTH - thumbnail.width) // 2
            )
            image_y = y + MARGIN

            sheet.paste(
                thumbnail,
                (image_x, image_y),
            )

        except Exception as exc:
            errors.append((image_path.name, str(exc)))

            draw.text(
                (x + MARGIN, y + 65),
                "IMAGE ERROR",
                fill=(180, 0, 0),
                font=font,
            )

        label_y = (
            y + CELL_HEIGHT - LABEL_HEIGHT - 6
        )

        draw.text(
            (x + MARGIN, label_y),
            image_path.name,
            fill=TEXT_COLOR,
            font=font,
        )

    output_path = (
        output_dir
        / f"{output_prefix}_contact_sheet_{page_number:02d}.png"
    )

    # Never silently overwrite an earlier review sheet.
    if output_path.exists():
        raise FileExistsError(
            f"Output already exists: {output_path}"
        )

    with output_path.open("xb") as output:
        sheet.save(output, format="PNG")

    return output_path, errors


def generate_review(images, output_dir=OUTPUT_DIR, output_prefix="rohu"):
    print("=" * 60)
    print(f"SariwaBa Model A - {output_prefix} Visual Dataset Review")
    print("=" * 60)

    print(f"Images discovered: {len(images)}")

    if not images:
        print("No images found.")
        return

    per_page = COLUMNS * ROWS

    total_pages = math.ceil(
        len(images) / per_page
    )

    output_dir.mkdir(
        parents=True,
        exist_ok=True,
    )

    font = get_font()
    all_errors = []

    # Verify that no output pages would be overwritten.
    for page_number in range(1, total_pages + 1):
        output_path = (
            output_dir
            / f"{output_prefix}_contact_sheet_{page_number:02d}.png"
        )

        if output_path.exists():
            raise FileExistsError(
                f"Contact sheet already exists: {output_path}"
            )

    for page_index in range(total_pages):
        start = page_index * per_page
        end = start + per_page

        page_images = images[start:end]

        output_path, errors = create_contact_sheet(
            page_images,
            page_index + 1,
            font,
            output_dir,
            output_prefix,
        )

        all_errors.extend(errors)

        print(
            f"Page {page_index + 1}/{total_pages}: "
            f"{output_path}"
        )

    print()
    print("SUMMARY")
    print("-" * 60)

    print(f"Total images: {len(images)}")
    print(f"Contact sheets: {total_pages}")
    print(f"Image read errors: {len(all_errors)}")

    for filename, error in all_errors:
        print(f"  ERROR: {filename} - {error}")

    print()
    print("Review output directory:")
    print(output_dir)

    print()
    print("IMPORTANT:")
    print("- Original dataset images were not modified.")
    print("- Metadata manifests were not modified.")
    print("- No model training was performed.")
    print("- Visual similarity does not prove duplication.")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dataset", choices=("rohu", "v2"), default="rohu")
    args = parser.parse_args()
    if args.dataset == "rohu":
        generate_review(collect_images())
        return

    output_dir = BASE_DIR / "ml" / "results" / "validator_v2_review"
    batches = []
    for label in ("eye", "gill"):
        source_dir = BASE_DIR / "datasets" / "validator_v2_candidates" / label
        images = collect_images(source_dir, "")
        prefix = f"v2_{label}"
        # Check both classes before writing any pages.
        for page in range(1, math.ceil(len(images) / (COLUMNS * ROWS)) + 1):
            target = output_dir / f"{prefix}_contact_sheet_{page:02d}.png"
            if target.exists():
                raise FileExistsError(f"Contact sheet already exists: {target}")
        batches.append((images, prefix))
    for images, prefix in batches:
        generate_review(images, output_dir, prefix)


if __name__ == "__main__":
    main()

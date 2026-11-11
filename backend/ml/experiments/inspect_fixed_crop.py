from pathlib import Path
import random

from PIL import Image, ImageDraw, ImageFont


# ---------------------------------------------------------
# CONFIG
# ---------------------------------------------------------

PROJECT_ROOT = Path(__file__).resolve().parents[2]
DATASET_ROOT = PROJECT_ROOT / "datasets"

OUTPUT_DIR = Path(__file__).resolve().parent / "crop_inspection"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

SAMPLES_PER_CLASS = 8
RANDOM_SEED = 42

# Assumption for this experiment:
# fish head is usually positioned toward the LEFT side.
HEAD_SIDE = "left"

# Percentage of whole image used as approximate head/eye crop.
CROP_WIDTH_RATIO = 0.42

# Remove a little of the extreme top/bottom.
CROP_TOP_RATIO = 0.08
CROP_BOTTOM_RATIO = 0.82

VALID_EXTENSIONS = {".jpg", ".jpeg", ".png"}


# ---------------------------------------------------------
# HELPERS
# ---------------------------------------------------------

def find_class_images(keyword: str):
    matches = []

    for path in DATASET_ROOT.rglob("*"):
        if not path.is_file():
            continue

        if path.suffix.lower() not in VALID_EXTENSIONS:
            continue

        parts = [part.lower() for part in path.parts]

        if keyword.lower() == "fresh":
            # Fresh but NOT NonFresh
            if (
                any("fresh" == p for p in parts)
                and not any(
                    p in {"nonfresh", "notfresh", "not_fresh", "non_fresh"}
                    for p in parts
                )
            ):
                matches.append(path)

        elif keyword.lower() == "nonfresh":
            if any(
                p in {"nonfresh", "notfresh", "not_fresh", "non_fresh"}
                for p in parts
            ):
                matches.append(path)

    return matches


def fixed_head_crop_box(width: int, height: int):
    crop_width = int(width * CROP_WIDTH_RATIO)

    top = int(height * CROP_TOP_RATIO)
    bottom = int(height * CROP_BOTTOM_RATIO)

    if HEAD_SIDE == "left":
        left = 0
        right = crop_width
    else:
        left = width - crop_width
        right = width

    return left, top, right, bottom


def fit_image(image: Image.Image, target_width: int, target_height: int):
    image = image.copy()
    image.thumbnail((target_width, target_height))

    canvas = Image.new("RGB", (target_width, target_height), "white")

    x = (target_width - image.width) // 2
    y = (target_height - image.height) // 2

    canvas.paste(image, (x, y))
    return canvas


def make_comparison(image_path: Path, label: str, index: int):
    with Image.open(image_path) as source:
        source = source.convert("RGB")

        width, height = source.size

        box = fixed_head_crop_box(width, height)

        marked = source.copy()
        draw = ImageDraw.Draw(marked)
        draw.rectangle(
            box,
            outline="red",
            width=max(3, width // 200),
        )

        crop = source.crop(box)

        preview_width = 600
        preview_height = 450

        whole_preview = fit_image(
            marked,
            preview_width,
            preview_height,
        )

        crop_preview = fit_image(
            crop,
            preview_width,
            preview_height,
        )

        title_height = 70

        comparison = Image.new(
            "RGB",
            (
                preview_width * 2,
                preview_height + title_height,
            ),
            "white",
        )

        comparison.paste(
            whole_preview,
            (0, title_height),
        )

        comparison.paste(
            crop_preview,
            (preview_width, title_height),
        )

        draw = ImageDraw.Draw(comparison)

        draw.text(
            (20, 15),
            f"{label} #{index} | WHOLE IMAGE + CROP BOX",
            fill="black",
        )

        draw.text(
            (preview_width + 20, 15),
            "FIXED HEAD / EYE CROP",
            fill="black",
        )

        filename = (
            f"{label.lower()}_{index:02d}_"
            f"{image_path.stem}.jpg"
        )

        output_path = OUTPUT_DIR / filename
        comparison.save(output_path, quality=92)

        return output_path


# ---------------------------------------------------------
# MAIN
# ---------------------------------------------------------

def main():
    random.seed(RANDOM_SEED)

    print("Dataset root:")
    print(DATASET_ROOT)
    print()

    fresh_images = find_class_images("fresh")
    nonfresh_images = find_class_images("nonfresh")

    print(f"Fresh images found: {len(fresh_images)}")
    print(f"NonFresh images found: {len(nonfresh_images)}")
    print()

    if not fresh_images:
        raise RuntimeError(
            "No Fresh images were found. "
            "Check DATASET_ROOT or dataset folder names."
        )

    if not nonfresh_images:
        raise RuntimeError(
            "No NonFresh images were found. "
            "Check DATASET_ROOT or dataset folder names."
        )

    fresh_sample = random.sample(
        fresh_images,
        min(SAMPLES_PER_CLASS, len(fresh_images)),
    )

    nonfresh_sample = random.sample(
        nonfresh_images,
        min(SAMPLES_PER_CLASS, len(nonfresh_images)),
    )

    print("Creating crop inspection images...")
    print()

    for index, path in enumerate(fresh_sample, start=1):
        output = make_comparison(
            path,
            "Fresh",
            index,
        )
        print(f"[Fresh] {output.name}")

    for index, path in enumerate(nonfresh_sample, start=1):
        output = make_comparison(
            path,
            "NonFresh",
            index,
        )
        print(f"[NonFresh] {output.name}")

    print()
    print("DONE")
    print()
    print("Inspection folder:")
    print(OUTPUT_DIR)
    print()
    print(
        "Open the generated images and check whether the red box "
        "consistently contains the fish head/eye."
    )


if __name__ == "__main__":
    main()
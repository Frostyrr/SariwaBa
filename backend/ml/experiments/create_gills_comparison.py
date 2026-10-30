from pathlib import Path
import random

from PIL import Image, ImageDraw, ImageFont


BASE_DIR = Path(__file__).resolve().parent.parent

GILLS_DIR = (
    BASE_DIR
    / "datasets"
    / "tilapia"
    / "Fresh"
    / "Day 1"
    / "Gills"
)

OUTPUT_PATH = (
    BASE_DIR
    / "ml"
    / "results"
    / "fresh_gills_comparison.jpg"
)


FOLDERS = [
    "1_Gills_Day1",
    "2_Gills_Day1",
    "3_Gills_Day1",
]

VALID_EXTENSIONS = {
    ".jpg",
    ".jpeg",
    ".png",
}


SAMPLES_PER_FOLDER = 6
THUMBNAIL_WIDTH = 220
THUMBNAIL_HEIGHT = 300

LABEL_HEIGHT = 45

RANDOM_SEED = 42


random.seed(
    RANDOM_SEED
)


def get_images(folder):

    return sorted([
        path
        for path in folder.iterdir()
        if (
            path.is_file()
            and
            path.suffix.lower()
            in VALID_EXTENSIONS
        )
    ])


def choose_even_samples(images, count):

    if len(images) <= count:
        return images

    step = (
        (len(images) - 1)
        / (count - 1)
    )

    indices = [
        round(
            index * step
        )
        for index
        in range(count)
    ]

    return [
        images[index]
        for index
        in indices
    ]


rows = []


for folder_name in FOLDERS:

    folder = (
        GILLS_DIR
        / folder_name
    )

    images = get_images(
        folder
    )

    samples = choose_even_samples(
        images,
        SAMPLES_PER_FOLDER,
    )

    rows.append(
        (
            folder_name,
            samples,
        )
    )


canvas_width = (
    THUMBNAIL_WIDTH
    * SAMPLES_PER_FOLDER
)

canvas_height = (
    (
        THUMBNAIL_HEIGHT
        + LABEL_HEIGHT
    )
    * len(rows)
)


canvas = Image.new(
    "RGB",
    (
        canvas_width,
        canvas_height,
    ),
    "white",
)


draw = ImageDraw.Draw(
    canvas
)


for row_index, (
    folder_name,
    samples,
) in enumerate(
    rows
):

    row_y = (
        row_index
        * (
            THUMBNAIL_HEIGHT
            + LABEL_HEIGHT
        )
    )


    draw.text(
        (
            10,
            row_y + 10,
        ),
        folder_name,
        fill="black",
    )


    image_y = (
        row_y
        + LABEL_HEIGHT
    )


    for column_index, image_path in enumerate(
        samples
    ):

        with Image.open(
            image_path
        ) as image:

            image = image.convert(
                "RGB"
            )

            image.thumbnail(
                (
                    THUMBNAIL_WIDTH,
                    THUMBNAIL_HEIGHT,
                )
            )


            background = Image.new(
                "RGB",
                (
                    THUMBNAIL_WIDTH,
                    THUMBNAIL_HEIGHT,
                ),
                "white",
            )


            x_offset = (
                THUMBNAIL_WIDTH
                - image.width
            ) // 2

            y_offset = (
                THUMBNAIL_HEIGHT
                - image.height
            ) // 2


            background.paste(
                image,
                (
                    x_offset,
                    y_offset,
                ),
            )


            x = (
                column_index
                * THUMBNAIL_WIDTH
            )


            canvas.paste(
                background,
                (
                    x,
                    image_y,
                ),
            )


            draw.text(
                (
                    x + 5,
                    image_y + 5,
                ),
                image_path.name,
                fill="black",
            )


OUTPUT_PATH.parent.mkdir(
    parents=True,
    exist_ok=True,
)


canvas.save(
    OUTPUT_PATH,
    quality=95,
)


print("=" * 70)
print("Fresh Gills Comparison Created")
print("=" * 70)

print(
    f"\nSaved to:"
)

print(
    OUTPUT_PATH
)
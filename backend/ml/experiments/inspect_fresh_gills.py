from pathlib import Path
from collections import Counter

from PIL import Image, ImageStat


BASE_DIR = Path(__file__).resolve().parent.parent

FRESH_GILLS_DIR = (
    BASE_DIR
    / "datasets"
    / "tilapia"
    / "Fresh"
    / "Day 1"
    / "Gills"
)


VALID_EXTENSIONS = {
    ".jpg",
    ".jpeg",
    ".png",
    ".bmp",
    ".webp",
}


print("=" * 75)
print("SariwaBa Fresh Gills Dataset Inspection")
print("=" * 75)

print(
    f"\nDirectory: "
    f"{FRESH_GILLS_DIR}"
)


folders = sorted([
    path
    for path in FRESH_GILLS_DIR.iterdir()
    if path.is_dir()
])


for folder in folders:

    image_paths = [
        path
        for path in folder.iterdir()
        if path.is_file()
        and path.suffix.lower()
        in VALID_EXTENSIONS
    ]


    print(
        "\n"
        + "=" * 75
    )

    print(
        f"Folder: "
        f"{folder.name}"
    )

    print(
        f"Images: "
        f"{len(image_paths)}"
    )


    if not image_paths:
        continue


    resolutions = Counter()

    red_values = []
    green_values = []
    blue_values = []

    brightness_values = []


    unreadable = []


    for image_path in image_paths:

        try:

            with Image.open(
                image_path
            ) as image:

                image = image.convert(
                    "RGB"
                )


                resolutions[
                    image.size
                ] += 1


                stat = ImageStat.Stat(
                    image
                )


                mean_red = (
                    stat.mean[0]
                )

                mean_green = (
                    stat.mean[1]
                )

                mean_blue = (
                    stat.mean[2]
                )


                red_values.append(
                    mean_red
                )

                green_values.append(
                    mean_green
                )

                blue_values.append(
                    mean_blue
                )


                brightness = (
                    0.299
                    * mean_red
                    +
                    0.587
                    * mean_green
                    +
                    0.114
                    * mean_blue
                )


                brightness_values.append(
                    brightness
                )


        except Exception as error:

            unreadable.append(
                (
                    image_path.name,
                    str(error),
                )
            )


    print(
        "\nMost common resolutions:"
    )


    for resolution, count in (
        resolutions.most_common(5)
    ):

        print(
            f"  "
            f"{resolution[0]}"
            f"x"
            f"{resolution[1]}"
            f": "
            f"{count}"
        )


    if brightness_values:

        average_red = (
            sum(red_values)
            / len(red_values)
        )

        average_green = (
            sum(green_values)
            / len(green_values)
        )

        average_blue = (
            sum(blue_values)
            / len(blue_values)
        )

        average_brightness = (
            sum(brightness_values)
            / len(brightness_values)
        )


        print(
            "\nAverage RGB:"
        )

        print(
            f"  R: "
            f"{average_red:.2f}"
        )

        print(
            f"  G: "
            f"{average_green:.2f}"
        )

        print(
            f"  B: "
            f"{average_blue:.2f}"
        )


        print(
            f"\nAverage brightness: "
            f"{average_brightness:.2f}"
        )


    print(
        f"\nUnreadable images: "
        f"{len(unreadable)}"
    )


    if unreadable:

        for filename, error in (
            unreadable[:10]
        ):

            print(
                f"  "
                f"{filename}: "
                f"{error}"
            )


print(
    "\nInspection complete."
)
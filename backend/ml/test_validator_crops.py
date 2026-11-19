
"""
SariwaBa Model A - Crop Sensitivity Test

Compares original images against two predefined crops
using the existing experimental Model A checkpoint.

The crop rectangles are based on visual inspection.
They are diagnostic examples, not a general-purpose
automatic eye or gill detector.

Run from backend:
    python -m ml.test_validator_crops

Does not:
- Retrain or update either model
- Modify the original challenge images
- Modify dataset metadata or database records
- Change the Model B freshness checkpoint
"""

from pathlib import Path

import torch
from PIL import Image

from ml.test_validator_independent import (
    CLASS_NAMES,
    CHALLENGE_DIR,
    DEVICE,
    PREPROCESS,
    load_model,
)


BASE_DIR = Path(__file__).resolve().parent.parent

OUTPUT_DIR = (
    BASE_DIR
    / "ml"
    / "results"
    / "crop_sensitivity"
)

# Rectangles use relative coordinates:
# (left, top, right, bottom), each between 0 and 1.
#
# Review saved crops visually before interpreting results.
TEST_IMAGES = {
    "eye/testing_eye1.png": {
        "expected": "eye",
        "moderate": (0.12, 0.13, 0.80, 0.85),
        "tight": (0.23, 0.28, 0.62, 0.70),
    },
    "eye/testing_eye3.png": {
        "expected": "eye",
        "moderate": (0.18, 0.05, 0.84, 0.85),
        "tight": (0.33, 0.12, 0.70, 0.64),
    },
    "eye/testing_eye5.png": {
        "expected": "eye",
        "moderate": (0.08, 0.07, 0.82, 0.86),
        "tight": (0.22, 0.18, 0.65, 0.73),
    },
    "gill/testing_gills1.png": {
        "expected": "gill",
        "moderate": (0.14, 0.12, 0.84, 0.87),
        "tight": (0.22, 0.24, 0.75, 0.78),
    },
    "gill/testing_gills4.png": {
        "expected": "gill",
        "moderate": (0.11, 0.10, 0.90, 0.92),
        "tight": (0.22, 0.22, 0.78, 0.83),
    },
}


def make_crop(image, rectangle):
    width, height = image.size

    left, top, right, bottom = rectangle

    if not (
        0 <= left < right <= 1
        and 0 <= top < bottom <= 1
    ):
        raise ValueError(
            f"Invalid crop rectangle: {rectangle}"
        )

    box = (
        round(left * width),
        round(top * height),
        round(right * width),
        round(bottom * height),
    )

    return image.crop(box)


@torch.inference_mode()
def predict(model, image):
    tensor = PREPROCESS(image.convert("RGB"))
    tensor = tensor.unsqueeze(0).to(DEVICE)

    outputs = model(tensor)

    probabilities = torch.softmax(
        outputs,
        dim=1,
    )[0].cpu()

    index = int(probabilities.argmax().item())

    scores = {
        name: float(probabilities[i].item())
        for i, name in enumerate(CLASS_NAMES)
    }

    return {
        "label": CLASS_NAMES[index],
        "confidence": float(
            probabilities[index].item()
        ),
        "scores": scores,
    }


def display_prediction(name, prediction, expected):
    correct = prediction["label"] == expected

    status = "PASS" if correct else "FAIL"

    print(
        f"  [{status}] {name:<10}"
        f" Predicted: {prediction['label']:<12}"
        f" Confidence: {prediction['confidence']:.4f}"
    )

    print(
        "       Scores: "
        + " | ".join(
            f"{label}={score:.4f}"
            for label, score
            in prediction["scores"].items()
        )
    )

    return correct


def main():
    print("=" * 65)
    print("SariwaBa Model A - Crop Sensitivity Test")
    print("=" * 65)

    if OUTPUT_DIR.exists():
        raise FileExistsError(
            "Crop results directory already exists. "
            "Nothing overwritten:\n"
            f"{OUTPUT_DIR}"
        )

    # Validate all inputs before creating outputs.
    for relative_path in TEST_IMAGES:
        path = CHALLENGE_DIR / relative_path

        if not path.is_file():
            raise FileNotFoundError(
                f"Missing challenge image: {path}"
            )

    model, checkpoint = load_model()

    print("Device:", DEVICE)
    print("Checkpoint epoch:", checkpoint["best_epoch"])
    print("Images:", len(TEST_IMAGES))
    print()

    OUTPUT_DIR.mkdir(
        parents=True,
        exist_ok=False,
    )

    summary = {
        "original": 0,
        "moderate": 0,
        "tight": 0,
    }

    for relative_path, settings in (
        TEST_IMAGES.items()
    ):
        source_path = CHALLENGE_DIR / relative_path

        expected = settings["expected"]

        with Image.open(source_path) as source:
            original = source.convert("RGB")

        print("-" * 65)
        print("IMAGE:", relative_path)
        print("Expected:", expected)
        print("Original size:", original.size)

        original_prediction = predict(
            model, original
        )

        if display_prediction(
            "Original",
            original_prediction,
            expected,
        ):
            summary["original"] += 1

        base_name = (
            source_path.parent.name
            + "_"
            + source_path.stem
        )

        for crop_name in ("moderate", "tight"):
            cropped = make_crop(
                original,
                settings[crop_name],
            )

            output_path = (
                OUTPUT_DIR
                / f"{base_name}_{crop_name}.png"
            )

            cropped.save(
                output_path,
                format="PNG",
            )

            prediction = predict(
                model, cropped
            )

            if display_prediction(
                crop_name.capitalize(),
                prediction,
                expected,
            ):
                summary[crop_name] += 1

            print(
                f"       Crop size: {cropped.size}"
            )

            print(
                f"       Saved: {output_path.name}"
            )

        print()

    total = len(TEST_IMAGES)

    print("=" * 65)
    print("CROP SENSITIVITY SUMMARY")
    print("=" * 65)

    for crop_name, correct in summary.items():
        print(
            f"{crop_name.capitalize():<10}: "
            f"{correct}/{total} correct "
            f"({100 * correct / total:.1f}%)"
        )

    print()
    print("Cropped images saved to:")
    print(OUTPUT_DIR)

    print()
    print("IMPORTANT:")
    print("- Original challenge images were not changed.")
    print("- Both trained models remain unchanged.")
    print("- Crop rectangles require visual review.")
    print("- These images are diagnostic, not a new test set.")
    print("- No confidence threshold was calibrated.")
    print("- Species identity is not verified by Model A.")
    print("- No Django integration was performed.")


if __name__ == "__main__":
    main()

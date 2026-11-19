
"""
SariwaBa Model A - Unsupported Near-Duplicate Audit

Read-only screening using difference hashes (dHash).
Flags visually similar images for manual inspection.
Does not modify images, labels, splits, or checkpoints.
"""

from pathlib import Path
from PIL import Image
from ml.shared_dataset import SariwaBaSharedDataset


THRESHOLD = 5
MAX_DISPLAY = 30


def dhash(path):
    with Image.open(path) as original:
        image = original.convert("L").resize((9, 8))
        pixels = list(image.getdata())

    result = 0
    for row in range(8):
        for col in range(8):
            left = pixels[row * 9 + col]
            right = pixels[row * 9 + col + 1]
            result = (result << 1) | int(left > right)

    return result


def main():
    dataset = SariwaBaSharedDataset("validator")
    unsupported_id = dataset.class_to_idx["unsupported"]

    files = [
        path
        for path, label in dataset.samples
        if label == unsupported_id
    ]

    print("SariwaBa - Near-Duplicate Screening")
    print("=" * 60)
    print("Images checked:", len(files))
    print("Hamming-distance threshold:", THRESHOLD)

    hashes = []
    for path in files:
        try:
            hashes.append((path, dhash(path)))
        except Exception as exc:
            print("IMAGE ERROR:", path, exc)

    matches = []

    for index, (path_a, hash_a) in enumerate(hashes):
        for path_b, hash_b in hashes[index + 1:]:
            distance = (hash_a ^ hash_b).bit_count()

            if distance <= THRESHOLD:
                matches.append(
                    (distance, path_a, path_b)
                )

    matches.sort(key=lambda item: item[0])

    print("Successfully hashed:", len(hashes))
    print("Potentially similar pairs:", len(matches))
    print()

    for distance, path_a, path_b in matches[:MAX_DISPLAY]:
        print("Distance:", distance)
        print("  A:", path_a.relative_to(dataset_root()))
        print("  B:", path_b.relative_to(dataset_root()))
        print()

    if len(matches) > MAX_DISPLAY:
        print(
            "Additional pairs not displayed:",
            len(matches) - MAX_DISPLAY,
        )

    print("Screening completed. No files were modified.")
    print(
        "Matches are candidates, not confirmed duplicates."
    )


def dataset_root():
    return Path(__file__).resolve().parent.parent


if __name__ == "__main__":
    main()

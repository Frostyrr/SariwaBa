from pathlib import Path
from collections import defaultdict
import hashlib


BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "datasets" / "tilapia"


def file_hash(path):
    sha256 = hashlib.sha256()

    with open(path, "rb") as file:
        while True:
            chunk = file.read(1024 * 1024)

            if not chunk:
                break

            sha256.update(chunk)

    return sha256.hexdigest()


valid_extensions = {
    ".jpg",
    ".jpeg",
    ".png",
    ".bmp",
    ".webp",
}


image_paths = [
    path
    for path in DATA_DIR.rglob("*")
    if path.is_file()
    and path.suffix.lower() in valid_extensions
]


print("=" * 70)
print("SariwaBa Exact Duplicate Image Check")
print("=" * 70)

print(f"\nTotal images: {len(image_paths)}")


hash_groups = defaultdict(list)


for index, path in enumerate(
    image_paths,
    start=1,
):
    image_hash = file_hash(path)

    hash_groups[
        image_hash
    ].append(path)

    if index % 500 == 0:
        print(
            f"Checked {index}/{len(image_paths)} images..."
        )


duplicate_groups = {
    image_hash: paths
    for image_hash, paths in hash_groups.items()
    if len(paths) > 1
}


duplicate_extra_count = sum(
    len(paths) - 1
    for paths in duplicate_groups.values()
)


print("\n" + "=" * 70)
print("RESULTS")
print("=" * 70)

print(
    f"Duplicate groups: "
    f"{len(duplicate_groups)}"
)

print(
    f"Extra duplicate files: "
    f"{duplicate_extra_count}"
)


for group_number, paths in enumerate(
    duplicate_groups.values(),
    start=1,
):
    print(
        f"\nDuplicate Group {group_number}:"
    )

    for path in paths:
        print(
            f"  {path.relative_to(DATA_DIR)}"
        )


print(
    "\nDuplicate check complete."
)
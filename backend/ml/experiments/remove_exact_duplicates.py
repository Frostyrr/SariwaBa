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


hash_groups = defaultdict(list)


for path in image_paths:
    hash_groups[
        file_hash(path)
    ].append(path)


duplicate_groups = [
    paths
    for paths in hash_groups.values()
    if len(paths) > 1
]


files_to_delete = []


for paths in duplicate_groups:

    # Prefer keeping the filename without "(1)"
    preferred = [
        path
        for path in paths
        if "(1)" not in path.stem
    ]

    if preferred:
        keep_file = preferred[0]
    else:
        keep_file = paths[0]

    for path in paths:
        if path != keep_file:
            files_to_delete.append(path)


print("=" * 70)
print("SariwaBa Duplicate Cleanup")
print("=" * 70)

print(
    f"\nDuplicate groups found: "
    f"{len(duplicate_groups)}"
)

print(
    f"Files scheduled for deletion: "
    f"{len(files_to_delete)}"
)


print("\nFiles to delete:")

for path in files_to_delete:
    print(
        path.relative_to(DATA_DIR)
    )


confirmation = input(
    "\nType DELETE to remove these exact duplicate files: "
)


if confirmation != "DELETE":
    print("\nCleanup cancelled.")

else:

    deleted_count = 0

    for path in files_to_delete:
        path.unlink()
        deleted_count += 1

    print(
        f"\nDeleted "
        f"{deleted_count} duplicate files."
    )

    print(
        "\nDuplicate cleanup complete."
    )
"""Build a leak-free, multi-source Model B freshness manifest (train/val/test).

Combines deduplicated eye/gill imagery from Tilapia_Dataset1, Tilapia_Dataset2,
subsampled datasets/tilapia (keeping each video/specimen folder wholly in one split),
and optional local Fresh / Non-Fresh directories (e.g. Day 1-2 Fresh and Day 3-4 Non-Fresh).

Usage (from backend):
    python -m ml.prepare_freshness_manifest --output datasets/local_collection/validator_v2_metadata/model_b_unified_manifest.csv
"""
import argparse
import csv
import hashlib
from collections import Counter
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
DATASETS_DIR = BASE_DIR / "datasets"
CHALLENGE_DIR = BASE_DIR / "ml" / "challenge_images"
EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def rel_path(path: Path) -> str:
    return path.resolve().relative_to(BASE_DIR.resolve()).as_posix()


def list_images(folder: Path):
    if not folder.exists():
        return []
    return sorted(
        p for p in folder.rglob("*")
        if p.is_file() and p.suffix.lower() in EXTENSIONS
    )


def subsample(paths, limit):
    if limit is None or len(paths) <= limit:
        return list(paths)
    step = len(paths) / limit
    return [paths[int(i * step)] for i in range(limit)]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        type=Path,
        default=DATASETS_DIR / "local_collection/validator_v2_metadata/model_b_unified_manifest.csv",
    )
    parser.add_argument(
        "--include-local-fresh",
        action="store_true",
        help="Include local Day 1 (and optionally Day 2) eye/gill photos as Fresh in train.",
    )
    parser.add_argument(
        "--local-nonfresh-dirs",
        type=Path,
        nargs="*",
        default=[],
        help="Optional local Non-Fresh eye/gill folders (e.g. Day 3/Day 4) to add to train.",
    )
    parser.add_argument("--kaggle-cap-per-group", type=int, default=40)
    args = parser.parse_args()

    protected_hashes = {sha256_file(p) for p in list_images(CHALLENGE_DIR)}
    seen_hashes = set()
    rows = []

    def add(path: Path, region: str, freshness: str, group_key: str, split: str, source: str):
        h = sha256_file(path)
        if h in protected_hashes or h in seen_hashes:
            return False
        seen_hashes.add(h)
        rows.append({
            "image_path": rel_path(path),
            "region": region,
            "freshness_label": freshness,
            "label_source": source,
            "group_key": group_key,
            "split": split,
        })
        return True

    # 1. Tilapia_Dataset1 & Tilapia_Dataset2 (mata=eye, insang=gill; skip kulit=whole/skin)
    for ds_name in ("Tilapia_Dataset1", "Tilapia_Dataset2"):
        ds_root = DATASETS_DIR / ds_name
        if not ds_root.exists():
            continue
        for ds_split, out_split in (("train", "train"), ("valid", "val"), ("test", "test")):
            for cls_dir, freshness in (("Segar", "Fresh"), ("Tidak Segar", "NonFresh")):
                for p in list_images(ds_root / ds_split / cls_dir):
                    name = p.name.lower()
                    if name.startswith("mata_"):
                        region = "eye"
                    elif name.startswith("insang_"):
                        region = "gill"
                    else:
                        continue
                    add(p, region, freshness, f"{ds_name}_{out_split}_{cls_dir}_{region}", out_split, ds_name)

    # 2. Kaggle datasets/tilapia (subsampled per specimen/day folder; NO 50-frame block leakage!)
    til = DATASETS_DIR / "tilapia"
    kaggle_plan = [
        # (relative folder, region, freshness, group_key, split)
        ("Fresh/Day 1/Eyes/1_Eyes", "eye", "Fresh", "kaggle_f_eye_1", "train"),
        ("Fresh/Day 1/Eyes/3_Eyes", "eye", "Fresh", "kaggle_f_eye_3", "train"),
        ("Fresh/Day 1/Eyes/5_Eyes", "eye", "Fresh", "kaggle_f_eye_5", "train"),
        ("Fresh/Day 1/Eyes/6_Eyes", "eye", "Fresh", "kaggle_f_eye_6", "train"),
        ("Fresh/Day 1/Eyes/4_Eyes", "eye", "Fresh", "kaggle_f_eye_4", "val"),
        ("Fresh/Day 1/Eyes/7_Eyes", "eye", "Fresh", "kaggle_f_eye_7", "test"),
        ("Fresh/Day 1/Gills/1_Gills_Day1", "gill", "Fresh", "kaggle_f_gill_1", "train"),
        ("Fresh/Day 1/Gills/2_Gills_Day1", "gill", "Fresh", "kaggle_f_gill_2", "train"),
        ("Fresh/Day 1/Gills/3_Gills_Day1", "gill", "Fresh", "kaggle_f_gill_3", "val"),
        ("NonFresh/Day 2/Eyes", "eye", "NonFresh", "kaggle_nf_eye_d2", "train"),
        ("NonFresh/Day 3/Eyes", "eye", "NonFresh", "kaggle_nf_eye_d3", "val"),
        ("NonFresh/Day 4/Eyes", "eye", "NonFresh", "kaggle_nf_eye_d4", "test"),
        ("NonFresh/Day 2/Gills", "gill", "NonFresh", "kaggle_nf_gill_d2", "train"),
        ("NonFresh/Day 3/Gills", "gill", "NonFresh", "kaggle_nf_gill_d3", "val"),
        ("NonFresh/Day 4/Gills", "gill", "NonFresh", "kaggle_nf_gill_d4", "test"),
    ]
    for rel_folder, region, freshness, gk, sp in kaggle_plan:
        for p in subsample(list_images(til / rel_folder), args.kaggle_cap_per_group):
            add(p, region, freshness, gk, sp, "kaggle_tilapia")

    # 3. Optional local Fresh & Non-Fresh photos (keep entire Nov 21 batch in train)
    if args.include_local_fresh:
        local_fresh = [
            (DATASETS_DIR / "local_collection/android/day 1/eyes", "eye"),
            (DATASETS_DIR / "local_collection/android/day 1/gills", "gill"),
            (DATASETS_DIR / "local_collection/iphone_jpg/day_01/eyes", "eye"),
            (DATASETS_DIR / "local_collection/iphone_jpg/day_01/gills", "gill"),
        ]
        for folder, region in local_fresh:
            for p in subsample(list_images(folder), 60):
                add(p, region, "Fresh", "local_batch_2026_11_21", "train", "local_day1_fresh")

    for nf_dir in args.local_nonfresh_dirs:
        nf_path = nf_dir if nf_dir.is_absolute() else (BASE_DIR / nf_dir)
        region = "gill" if "gill" in nf_path.name.lower() else "eye"
        for p in subsample(list_images(nf_path), 80):
            add(p, region, "NonFresh", "local_batch_2026_11_21", "train", "local_nonfresh")

    out_path = args.output if args.output.is_absolute() else (BASE_DIR / args.output)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=["image_path", "region", "freshness_label", "label_source", "group_key", "split"],
        )
        writer.writeheader()
        writer.writerows(rows)

    counts = Counter((r["split"], r["freshness_label"], r["region"]) for r in rows)
    print(f"Wrote {len(rows)} deduplicated records to {out_path}")
    for k, v in sorted(counts.items()):
        print(f"  {k}: {v}")


if __name__ == "__main__":
    main()

"""Refresh inventory without inventing specimen identities or split assignments.

Run from backend: python -m ml.validator_data --refresh
"""
import argparse
import csv
import hashlib
from collections import Counter, defaultdict
from pathlib import Path

from .prepare_shared_dataset import prepare_records
from .shared_dataset import BASE_DIR, METADATA_DIR, read_csv


def write_rows(path, rows, columns):
    temporary = path.with_suffix(".csv.tmp")
    with temporary.open("w", newline="", encoding="utf-8") as output:
        writer = csv.DictWriter(output, fieldnames=columns)
        writer.writeheader()
        writer.writerows(rows)
    temporary.replace(path)


def refresh_inventory(metadata_dir=METADATA_DIR):
    """Append new images only; retain all existing labels and reviewed assignments."""
    metadata_dir = Path(metadata_dir)
    freshness, validator, splits, _ = prepare_records()
    for name, discovered in [("freshness_labels.csv", freshness), ("validator_labels.csv", validator), ("splits.csv", splits)]:
        path = metadata_dir / name
        existing = read_csv(path)
        known = {row["image_path"] for row in existing}
        if len(known) != len(existing):
            raise ValueError(f"Duplicate records in {name}.")
        additions = [row for row in discovered if row["image_path"] not in known]
        columns = list(existing[0]) if existing else list(discovered[0])
        rows = existing + [{key: row.get(key, "") for key in columns} for row in additions]
        write_rows(path, rows, columns)
        print(f"{name}: appended {len(additions)} images; assignments preserved.")


def audit_partitions(metadata_dir=METADATA_DIR):
    """Require explicit reviewed grouping; check specimens and exact duplicates."""
    metadata_dir = Path(metadata_dir)
    records = read_csv(metadata_dir / "validator_labels.csv")
    assignments = read_csv(metadata_dir / "splits.csv")
    lookup = {row["image_path"]: row for row in assignments}
    if len(lookup) != len(assignments):
        raise ValueError("Duplicate split records.")
    seen = set()
    group_splits = defaultdict(set)
    counts = {name: Counter() for name in ("train", "val", "test")}
    for row in records:
        path = row["image_path"]
        if path in seen:
            raise ValueError(f"Duplicate validator record: {path}")
        seen.add(path)
        split_row = lookup.get(path, {})
        split = split_row.get("split")
        if split not in counts or split_row.get("split_status") != "verified":
            raise ValueError(f"Unreviewed/unassigned split: {path}. Review splits.csv first.")
        group = split_row.get("group_key", "").strip()
        specimen = split_row.get("specimen_id", "").strip()
        if not group or (row["anatomical_label"] != "unsupported" and not specimen):
            raise ValueError(f"Verified capture group and positive specimen ID required: {path}")
        group_splits[("capture", group)].add(split)
        if specimen:
            group_splits[("specimen", specimen)].add(split)
        counts[split][row["anatomical_label"]] += 1
    if any(len(partitions) > 1 for partitions in group_splits.values()):
        raise ValueError("A specimen or capture/source group occurs in multiple partitions.")
    hashes = defaultdict(set)
    for row in records:
        relative = Path(row["image_path"])
        path = (BASE_DIR / relative).resolve()
        if relative.is_absolute() or ".." in relative.parts or not path.is_relative_to(BASE_DIR):
            raise ValueError(f"Invalid image path: {relative}")
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        hashes[digest].add(lookup[row["image_path"]]["split"])
    if any(len(partitions) > 1 for partitions in hashes.values()):
        raise ValueError("Byte-identical images occur in multiple partitions.")
    return counts


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--refresh", action="store_true")
    parser.add_argument("--audit", action="store_true")
    args = parser.parse_args()
    if args.refresh:
        refresh_inventory()
    for name in ("validator_labels.csv", "splits.csv"):
        rows = read_csv(METADATA_DIR / name)
        field = "anatomical_label" if name.startswith("validator") else "split_status"
        print(name, len(rows), dict(Counter(row[field] for row in rows)))
    if args.audit:
        print(audit_partitions())


if __name__ == "__main__":
    main()

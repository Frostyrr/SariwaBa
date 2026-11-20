"""Audit a session-based fish/eye export and optionally train a YOLO pilot."""

import argparse
import hashlib
import json
import math
from collections import Counter
from pathlib import Path

from PIL import Image


def audit(session):
    images = {path.stem: path for path in (session / "images").glob("*.jpg")}
    labels = {path.stem: path for path in (session / "labels").glob("*.txt")}
    if not images or images.keys() != labels.keys():
        raise ValueError(
            f"{session}: missing labels {sorted(images.keys() - labels.keys())}, "
            f"missing images {sorted(labels.keys() - images.keys())}, images {len(images)}"
        )

    counts = Counter()
    fingerprints = set()
    for stem, image_path in sorted(images.items()):
        with Image.open(image_path) as image:
            if image.format != "JPEG" or image.getexif().get(274, 1) != 1:
                raise ValueError(f"{image_path}: use an orientation-normalized JPEG.")
            image.verify()
        fingerprint = hashlib.sha256(image_path.read_bytes()).hexdigest()
        if fingerprint in fingerprints:
            raise ValueError(f"{image_path}: exact duplicate within the session.")
        fingerprints.add(fingerprint)
        boxes = set()
        for line_number, row in enumerate(labels[stem].read_text(encoding="utf-8").splitlines(), 1):
            try:
                cls, *coords = row.split()
                x, y, width, height = map(float, coords)
                if cls not in ("0", "1") or not all(math.isfinite(v) for v in (x, y, width, height)):
                    raise ValueError
                if not (0 < width <= 1 and 0 < height <= 1 and
                        -1e-7 <= x - width / 2 < x + width / 2 <= 1 + 1e-7 and
                        -1e-7 <= y - height / 2 < y + height / 2 <= 1 + 1e-7):
                    raise ValueError
                box = (cls, x, y, width, height)
                if box in boxes:
                    raise ValueError
                boxes.add(box)
                counts[cls] += 1
            except ValueError as exc:
                raise ValueError(f"{labels[stem]}:{line_number}: invalid or duplicate YOLO box.") from exc
    print(f"{session.name}: {len(images)} images, {counts['0']} fish, {counts['1']} eyes", flush=True)
    return fingerprints


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("train_session", type=Path)
    parser.add_argument("--val-session", type=Path)
    parser.add_argument("--weights", help="Path or name of a pretrained Ultralytics detection checkpoint.")
    parser.add_argument("--output", type=Path, help="New directory for the training run.")
    parser.add_argument("--epochs", type=int, default=10)
    parser.add_argument("--image-size", type=int, default=640)
    parser.add_argument("--device", default="cpu")
    parser.add_argument("--smoke", action="store_true",
                        help="Reuse the training session only to check that training runs.")
    args = parser.parse_args()
    train = args.train_session.resolve()
    train_hashes = audit(train)
    val = args.val_session.resolve() if args.val_session else None
    if val and (val == train or train_hashes & audit(val)):
        parser.error("Training and validation must use separate sessions and images.")
    if not args.weights:
        return
    if args.output is None or args.output.exists():
        parser.error("Supply a new --output directory.")
    if args.smoke == (val is not None):
        parser.error("Choose either --smoke or --val-session for training.")
    if args.epochs < 1 or args.image_size < 32:
        parser.error("Use positive epochs and an image size of at least 32.")

    try:
        from ultralytics import YOLO
    except ImportError:
        parser.exit(1, "Ultralytics is required in the pilot Python environment.\n")

    output = args.output.resolve()
    output.mkdir(parents=True)
    config = output / "dataset.yaml"
    config.write_text(
        f"train: {json.dumps((train / 'images').as_posix())}\n"
        f"val: {json.dumps(((val or train) / 'images').as_posix())}\n"
        "names:\n  0: fish\n  1: eye\n",
        encoding="utf-8",
    )
    if args.smoke:
        (output / "SMOKE_ONLY.txt").write_text(
            "Training and validation use the same images. Scores do not estimate performance on new fish.\n",
            encoding="utf-8",
        )
    YOLO(args.weights).train(
        data=str(config), epochs=args.epochs, imgsz=args.image_size,
        device=args.device, workers=0, project=str(output), name="training",
    )


if __name__ == "__main__":
    main()

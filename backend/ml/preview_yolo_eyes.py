"""Generate a local review gallery of YOLO eye proposals on whole-fish photos."""

import argparse
import base64
import html
import io
import json
import math
from pathlib import Path

from PIL import Image, ImageOps


def padded_crop(box, width, height):
    left, top, right, bottom = box
    side = min(width, height, math.ceil(2.5 * max(right - left, bottom - top)))
    if side < 1:
        raise ValueError("Eye box must have positive area.")
    x = max(0, min(width - side, round((left + right - side) / 2)))
    y = max(0, min(height - side, round((top + bottom - side) / 2)))
    return [x, y, x + side, y + side]


def preview_image(image):
    thumbnail = image.copy()
    thumbnail.thumbnail((1000, 1000))
    buffer = io.BytesIO()
    thumbnail.save(buffer, format="JPEG", quality=90)
    return "data:image/jpeg;base64," + base64.b64encode(buffer.getvalue()).decode("ascii")


def review_card(path, image, detections):
    width, height = image.size
    uri = preview_image(image)
    source = f'<image href="{uri}" width="{width}" height="{height}"/>'
    boxes, crops = [], []
    for detection in detections:
        left, top, right, bottom = detection["box_xyxy"]
        color = "#ffdc45" if detection["class"] == "eye" else "#42e1ff"
        boxes.append(
            f'<rect x="{left}" y="{top}" width="{right-left}" height="{bottom-top}" '
            f'fill="none" stroke="{color}" stroke-width="2" vector-effect="non-scaling-stroke"/>'
        )
        if "crop_xyxy" in detection:
            x, y, r, b = detection["crop_xyxy"]
            crops.append(f'<figure><svg viewBox="{x} {y} {r-x} {b-y}">{source}</svg>'
                         f'<figcaption>Eye score {detection["score"]:.0%}</figcaption></figure>')
    gallery = "".join(crops) or "<p>No eye proposed. Use a manual crop or retake.</p>"
    return (f"<section><h2>{html.escape(path.name)}</h2>"
            f'<svg class="whole" viewBox="0 0 {width} {height}">{source}{"".join(boxes)}</svg>'
            f'<div class="crops">{gallery}</div></section>')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--checkpoint", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--confidence", type=float, default=0.25)
    parser.add_argument("images", nargs="+", type=Path)
    args = parser.parse_args()
    if not 0 < args.confidence <= 1 or args.output.exists():
        parser.error("Use a confidence between 0 and 1 and a new output directory.")
    if not args.checkpoint.is_file() or any(not path.is_file() for path in args.images):
        parser.error("The checkpoint and every image must be existing local files.")

    from ultralytics import YOLO
    model = YOLO(str(args.checkpoint))
    if model.names != {0: "fish", 1: "eye"}:
        parser.error("Expected the fish/eye pilot checkpoint.")
    records, cards = [], []
    for path in args.images:
        with Image.open(path) as raw:
            image = ImageOps.exif_transpose(raw).convert("RGB")
        result = model.predict(image, device="cpu", imgsz=640, conf=args.confidence, verbose=False)[0]
        detections = []
        for coords, score, index in zip(result.boxes.xyxy.tolist(), result.boxes.conf.tolist(),
                                        result.boxes.cls.tolist()):
            label = result.names[int(index)]
            entry = {"class": label, "score": score, "box_xyxy": coords}
            if label == "eye":
                entry["crop_xyxy"] = padded_crop(coords, *image.size)
            detections.append(entry)
        records.append({"image": str(path.resolve()), "size": image.size, "detections": detections})
        cards.append(review_card(path, image, detections))
        print(f"{path.name}: {sum(d['class'] == 'eye' for d in detections)} eye proposals", flush=True)

    args.output.mkdir(parents=True)
    (args.output / "predictions.json").write_text(json.dumps({
        "checkpoint": str(args.checkpoint.resolve()),
        "minimum_detection_score": args.confidence,
        "images": records,
    }, indent=2), encoding="utf-8")
    (args.output / "index.html").write_text(
        '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
        '<title>Tilapia eye proposal review</title><style>'
        'body{font:16px system-ui;margin:24px;color:#ecf7fa;background:#102023}'
        'main{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,330px),1fr));gap:16px}'
        'section{padding:14px;background:#1b3035}h2{font-size:16px}.whole{width:100%;height:360px}'
        '.crops{display:flex;flex-wrap:wrap;gap:8px}figure{margin:0;width:130px}figure svg{width:100%}</style>'
        '<h1>Tilapia eye proposal review</h1><p>Cyan boxes are fish and yellow boxes are eyes. '
        'Crops are proposed from the original image coordinates.</p><main>' + "".join(cards) + "</main>",
        encoding="utf-8",
    )


if __name__ == "__main__":
    main()

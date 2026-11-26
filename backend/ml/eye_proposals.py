"""Run the optional fish/eye detector on an orientation-normalized image."""

import math
import os
from functools import lru_cache
from pathlib import Path
from threading import Lock

from ml.predict import DEVICE
from ml.preview_yolo_eyes import padded_crop


class DetectorUnavailable(Exception):
    pass


_inference_lock = Lock()
DEFAULT_CHECKPOINT = Path(__file__).resolve().parent / "models" / "sariwaba_eye_detector.pt"


@lru_cache(maxsize=1)
def _load_detector(checkpoint):
    from ultralytics import YOLO

    model = YOLO(checkpoint, task="detect")
    if model.names != {0: "fish", 1: "eye"}:
        raise ValueError("Expected a fish/eye detector with the pilot class mapping.")
    return model


def _eye_inside_fish(eye_box, fish_boxes, margin_ratio=0.12):
    if not fish_boxes:
        return True
    ex = (eye_box[0] + eye_box[2]) / 2.0
    ey = (eye_box[1] + eye_box[3]) / 2.0
    for fl, ft, fr, fb in fish_boxes:
        mx = (fr - fl) * margin_ratio
        my = (fb - ft) * margin_ratio
        if (fl - mx) <= ex <= (fr + mx) and (ft - my) <= ey <= (fb + my):
            return True
    return False


def propose_eye_crops(image):
    override = os.environ.get("EYE_DETECTOR_CHECKPOINT")
    checkpoint = Path(override) if override else DEFAULT_CHECKPOINT
    if not checkpoint.is_file():
        raise DetectorUnavailable

    try:
        with _inference_lock:
            model = _load_detector(str(checkpoint.resolve()))
            result = model.predict(
                image, device=str(DEVICE), imgsz=640, conf=0.25, classes=[0, 1],
                max_det=16, verbose=False,
            )[0]
            xyxy_list = result.boxes.xyxy.tolist()
            cls_list = result.boxes.cls.tolist() if result.boxes.cls is not None else [1] * len(xyxy_list)
            conf_list = result.boxes.conf.tolist() if result.boxes.conf is not None else [1.0] * len(xyxy_list)
    except Exception as exc:
        raise DetectorUnavailable from exc

    fish_boxes = [
        coords for coords, cls_id in zip(xyxy_list, cls_list)
        if int(cls_id) == 0 and all(math.isfinite(v) for v in coords)
    ]
    eye_candidates = []
    for coords, cls_id, conf in zip(xyxy_list, cls_list, conf_list):
        if int(cls_id) != 1:
            continue
        left, top, right, bottom = coords
        if not all(math.isfinite(value) for value in coords):
            continue
        if not (0 <= left < right <= image.width and 0 <= top < bottom <= image.height):
            continue
        in_fish = _eye_inside_fish(coords, fish_boxes)
        # Drop low-confidence stray reflections outside all detected fish bodies
        if fish_boxes and not in_fish and float(conf) < 0.45:
            continue
        eye_candidates.append((in_fish, float(conf), (left, top, right, bottom)))

    # Prioritize eyes contained inside a detected fish body, then highest detector confidence
    eye_candidates.sort(key=lambda item: (item[0], item[1]), reverse=True)

    for _in_fish, _conf, coordinates in eye_candidates[:8]:
        left, top, right, bottom = coordinates
        yield padded_crop(coordinates, *image.size), (
            (left + right) / (2 * image.width),
            (top + bottom) / (2 * image.height),
        )

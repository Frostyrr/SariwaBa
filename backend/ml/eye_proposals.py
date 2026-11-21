"""Run the optional fish/eye detector on an orientation-normalized image."""

import math
import os
from functools import lru_cache
from pathlib import Path
from threading import Lock

from ml.preview_yolo_eyes import padded_crop


class DetectorUnavailable(Exception):
    pass


_inference_lock = Lock()


@lru_cache(maxsize=1)
def _load_detector(checkpoint):
    from ultralytics import YOLO

    model = YOLO(checkpoint, task="detect")
    if model.names != {0: "fish", 1: "eye"}:
        raise ValueError("Expected a fish/eye detector with the pilot class mapping.")
    return model


def propose_eye_crops(image):
    checkpoint = os.environ.get("EYE_DETECTOR_CHECKPOINT")
    if not checkpoint or not Path(checkpoint).is_file():
        raise DetectorUnavailable

    try:
        with _inference_lock:
            model = _load_detector(str(Path(checkpoint).resolve()))
            result = model.predict(
                image, device="cpu", imgsz=640, conf=0.25, classes=[1],
                max_det=8, verbose=False,
            )[0]
            boxes = result.boxes.xyxy.tolist()
    except Exception as exc:
        raise DetectorUnavailable from exc

    for left, top, right, bottom in boxes:
        coordinates = (left, top, right, bottom)
        if not all(math.isfinite(value) for value in coordinates):
            continue
        if not (0 <= left < right <= image.width and 0 <= top < bottom <= image.height):
            continue
        yield padded_crop(coordinates, *image.size)

"""Mandatory supported-input gate. A freshness score cannot verify species."""
import math
from pathlib import Path

import torch
from PIL import Image, ImageOps
from torch import nn
from torchvision import models

from .predict import DEVICE, ModelInferenceError, ModelUnavailableError, _build_eval_transform

VALIDATOR_PATH = Path(__file__).resolve().parent / "models" / "sariwaba_validator.pth"
VALIDATOR_CLASSES = ["eye", "gill", "unsupported"]
_BUNDLE = None


class InputRejectedError(ValueError):
    def __init__(self, code, message, confidence=None):
        super().__init__(message)
        self.code = code
        self.confidence = confidence


def get_validator_bundle(force_reload=False):
    global _BUNDLE
    if _BUNDLE is not None and not force_reload:
        return _BUNDLE
    try:
        checkpoint = torch.load(VALIDATOR_PATH, map_location=DEVICE, weights_only=True)
        if (checkpoint["classes"] != VALIDATOR_CLASSES
                or checkpoint["validation_scope"] != "tilapia_eye_gill"
                or checkpoint["threshold_source"] != "validation_split"):
            raise ValueError("Validator metadata does not match the supported-input contract.")
        threshold = float(checkpoint["acceptance_threshold"])
        if not math.isfinite(threshold) or not 0.5 <= threshold <= 1:
            raise ValueError("Invalid validator acceptance threshold.")
        evaluation = checkpoint["evaluation"]
        test = evaluation["test"]
        if (evaluation["acceptance_threshold"] != threshold
                or test["unsupported_false_accept_rate"] is None
                or not 0 <= test["unsupported_false_accept_rate"] <= evaluation["target_false_accept_rate"] < 1
                or any(test["class_counts"].get(label, 0) < evaluation["min_eval_per_class"]
                       for label in VALIDATOR_CLASSES)
                or evaluation["min_eval_per_class"] < 1
                or any(not 0 < rate <= 1 for rate in test["supported_correct_accept_rate"].values())
                or set(test["supported_correct_accept_rate"]) != {"eye", "gill"}):
            raise ValueError("Validator failed its held-out acceptance policy.")
        image_size = int(checkpoint["image_size"])
        if image_size != 224:
            raise ValueError("Unsupported validator preprocessing size.")
        net = models.mobilenet_v3_small(weights=None)
        net.classifier[3] = nn.Linear(net.classifier[3].in_features, 3)
        net.load_state_dict(checkpoint["model_state_dict"])
        net.to(DEVICE).eval()
        _BUNDLE = {
            "model": net, "transform": _build_eval_transform(image_size),
            "threshold": threshold, "model_version": checkpoint["model_version"],
        }
        return _BUNDLE
    except Exception as exc:
        raise ModelUnavailableError(
            "Supported-input validation is unavailable. A trained and evaluated "
            "Tilapia eye/gill validator must be installed before scanning."
        ) from exc


def decide_input(probabilities, region_type, threshold):
    """Shared by runtime, threshold selection, and held-out evaluation."""
    scores = [float(p) for p in probabilities]
    if (len(scores) != 3 or any(not math.isfinite(p) or not 0 <= p <= 1 for p in scores)
            or abs(sum(scores) - 1) > 1e-4):
        raise ModelInferenceError("Invalid validator probabilities.")
    index = max(range(3), key=scores.__getitem__)
    confidence = scores[index]
    label = VALIDATOR_CLASSES[index]
    if label == "unsupported":
        raise InputRejectedError("UNSUPPORTED_IMAGE",
            "Please submit a clear close-up of a Tilapia eye or exposed gill.", confidence)
    if confidence < threshold:
        raise InputRejectedError("CONTENT_UNCERTAIN",
            "The image could not be verified as a supported Tilapia eye or gill. Try another photo.", confidence)
    if label != region_type:
        raise InputRejectedError("REGION_MISMATCH",
            f"The image appears to show a {label}. Change the selected region or submit another image.", confidence)
    return {"region_verified": True, "species_verified": False,
            "validation_scope": "tilapia_eye_gill", "validation_confidence": confidence}


def validate_image(image_source, region_type):
    bundle = get_validator_bundle()
    try:
        if hasattr(image_source, "seek"):
            image_source.seek(0)
        with Image.open(image_source) as raw:
            tensor = bundle["transform"](ImageOps.exif_transpose(raw).convert("RGB"))
        with torch.inference_mode():
            probabilities = bundle["model"](tensor.unsqueeze(0).to(DEVICE)).softmax(1)[0].tolist()
    except Exception as exc:
        raise ModelInferenceError("Supported-input validation failed.") from exc
    result = decide_input(probabilities, region_type, bundle["threshold"])
    result["validator_version"] = bundle["model_version"]
    return result

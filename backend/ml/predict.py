from pathlib import Path
from typing import Any, Dict, Optional

import torch
from PIL import Image, ImageOps
from torch import nn
from torchvision import models, transforms


BASE_DIR = Path(__file__).resolve().parent.parent

MODEL_PATH = (
    BASE_DIR
    / "ml"
    / "models"
    / "sariwaba_mobilenetv3_best.pth"
)

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)


class ModelUnavailableError(RuntimeError):
    """Raised when the trained MobileNetV3 checkpoint is missing or invalid."""


class ModelInferenceError(RuntimeError):
    """Raised when MobileNetV3 inference fails during execution."""


_MODEL_BUNDLE: Optional[Dict[str, Any]] = None


def _build_eval_transform(image_size: int) -> transforms.Compose:
    return transforms.Compose([
        transforms.Resize((image_size, image_size)),
        transforms.ToTensor(),
        transforms.Normalize(
            mean=[0.485, 0.456, 0.406],
            std=[0.229, 0.224, 0.225],
        ),
    ])


def get_model_bundle(force_reload: bool = False) -> Dict[str, Any]:
    """
    Load and cache the trained MobileNetV3-Small model and metadata once.
    Raises ModelUnavailableError if the checkpoint file is missing or invalid.
    """
    global _MODEL_BUNDLE

    if _MODEL_BUNDLE is not None and not force_reload:
        return _MODEL_BUNDLE

    if not MODEL_PATH.exists() or not MODEL_PATH.is_file():
        raise ModelUnavailableError(
            f"Trained MobileNetV3 checkpoint not found at {MODEL_PATH}."
        )

    try:
        checkpoint = torch.load(
            MODEL_PATH,
            map_location=DEVICE,
            weights_only=False,
        )
    except Exception as exc:
        raise ModelUnavailableError(
            f"Failed to load MobileNetV3 checkpoint: {exc}"
        ) from exc

    if not isinstance(checkpoint, dict):
        raise ModelUnavailableError("Invalid checkpoint structure.")

    classes = checkpoint.get("classes")
    state_dict = checkpoint.get("model_state_dict")
    if not classes or not state_dict:
        raise ModelUnavailableError(
            "Checkpoint is missing required 'classes' or 'model_state_dict' keys."
        )

    image_size = int(checkpoint.get("image_size", 224))

    try:
        net = models.mobilenet_v3_small(weights=None)
        num_features = net.classifier[3].in_features
        net.classifier[3] = nn.Linear(num_features, len(classes))
        net.load_state_dict(state_dict)
        net = net.to(DEVICE)
        net.eval()
    except Exception as exc:
        raise ModelUnavailableError(
            f"Incompatible MobileNetV3 architecture or state_dict: {exc}"
        ) from exc

    _MODEL_BUNDLE = {
        "model": net,
        "classes": list(classes),
        "class_to_idx": checkpoint.get("class_to_idx", {}),
        "image_size": image_size,
        "transform": _build_eval_transform(image_size),
    }
    return _MODEL_BUNDLE


def normalize_label(label: str) -> str:
    if label == "NonFresh":
        return "Not Fresh"
    return label


def predict_image(
    image_source,
    region_type: Optional[str] = None,
) -> Dict[str, Any]:
    """
    Run MobileNetV3-Small inference on a validated Tilapia eye or gill image.
    """
    bundle = get_model_bundle()
    net = bundle["model"]
    classes = bundle["classes"]
    transform = bundle["transform"]

    try:
        if hasattr(image_source, "seek"):
            image_source.seek(0)

        with Image.open(image_source) as raw_img:
            oriented_img = ImageOps.exif_transpose(raw_img)
            rgb_img = oriented_img.convert("RGB")
            image_tensor = transform(rgb_img).unsqueeze(0).to(DEVICE)

        with torch.no_grad():
            outputs = net(image_tensor)
            probabilities = torch.softmax(outputs, dim=1)
            confidence, predicted_index = torch.max(probabilities, dim=1)

        raw_label = classes[predicted_index.item()]
        label = normalize_label(raw_label)

        return {
            "classification": label,
            "label": label,
            "confidence": float(confidence.item()),
            "raw_label": raw_label,
            "region_type": region_type,
            "model_variant": "mobilenet_v3_small",
            "image_size": bundle["image_size"],
        }
    except ModelUnavailableError:
        raise
    except Exception as exc:
        raise ModelInferenceError(
            f"MobileNetV3 inference execution failed: {exc}"
        ) from exc

from pathlib import Path

import torch
from PIL import Image
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


checkpoint = torch.load(
    MODEL_PATH,
    map_location=DEVICE,
    weights_only=False,
)

CLASSES = checkpoint["classes"]

IMAGE_SIZE = checkpoint.get(
    "image_size",
    224,
)


transform = transforms.Compose([
    transforms.Resize(
        (IMAGE_SIZE, IMAGE_SIZE)
    ),

    transforms.ToTensor(),

    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])


model = models.mobilenet_v3_small(
    weights=None
)

num_features = model.classifier[3].in_features

model.classifier[3] = nn.Linear(
    num_features,
    len(CLASSES),
)

model.load_state_dict(
    checkpoint["model_state_dict"]
)

model = model.to(DEVICE)

model.eval()


def normalize_label(label):
    if label == "NonFresh":
        return "Not Fresh"

    return label


def predict_image(image_source):
    image = Image.open(
        image_source
    ).convert("RGB")

    image_tensor = transform(
        image
    ).unsqueeze(0)

    image_tensor = image_tensor.to(
        DEVICE
    )

    with torch.no_grad():
        outputs = model(
            image_tensor
        )

        probabilities = torch.softmax(
            outputs,
            dim=1,
        )

        confidence, predicted_index = torch.max(
            probabilities,
            dim=1,
        )

    raw_label = CLASSES[
        predicted_index.item()
    ]

    label = normalize_label(
        raw_label
    )

    return {
        "label": label,
        "confidence": confidence.item(),
        "raw_label": raw_label,
    }
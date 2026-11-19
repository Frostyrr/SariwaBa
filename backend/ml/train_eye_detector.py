"""Train a fish and eye localization candidate using annotated whole photos."""

import argparse
import hashlib
from pathlib import Path

import torch
from torch.utils.data import DataLoader
from torchvision.models import MobileNet_V3_Large_Weights
from torchvision.models.detection import fasterrcnn_mobilenet_v3_large_fpn
from torchvision.ops import box_iou

from .eye_detection_data import CLASSES, EyeDetectionDataset, load_partitions


def build_detector(pretrained_backbone=False):
    return fasterrcnn_mobilenet_v3_large_fpn(
        weights=None,
        weights_backbone=MobileNet_V3_Large_Weights.DEFAULT if pretrained_backbone else None,
        num_classes=len(CLASSES),
        min_size=640,
        max_size=1280,
    )


def collate(batch):
    return tuple(zip(*batch))


@torch.inference_mode()
def evaluate(model, loader, device, score_threshold):
    model.eval()
    counts = {label: dict(tp=0, fp=0, fn=0) for label in CLASSES[1:]}
    for images, targets in loader:
        outputs = model([image.to(device) for image in images])
        for output, target in zip(outputs, targets):
            for index, label in enumerate(CLASSES[1:], start=1):
                keep = (output["labels"] == index) & (output["scores"] >= score_threshold)
                order = output["scores"][keep].argsort(descending=True)
                predicted = output["boxes"][keep][order].cpu()
                actual = target["boxes"][target["labels"] == index]
                overlaps = box_iou(predicted, actual)
                unmatched = set(range(len(actual)))
                for scores in overlaps:
                    match = max(sorted(unmatched), key=lambda idx: scores[idx], default=None)
                    if match is not None and scores[match] >= 0.5:
                        counts[label]["tp"] += 1
                        unmatched.remove(match)
                    else:
                        counts[label]["fp"] += 1
                counts[label]["fn"] += len(unmatched)
    return counts


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--epochs", type=int, default=10)
    parser.add_argument("--score-threshold", type=float, default=0.5)
    parser.add_argument("--audit-only", action="store_true")
    args = parser.parse_args()
    if not args.audit_only and (args.output is None or args.output.exists()):
        parser.error("Supply a new candidate checkpoint path with --output.")
    if args.epochs < 1 or not 0 <= args.score_threshold <= 1:
        parser.error("Use positive epochs and a score threshold between 0 and 1.")

    partitions = load_partitions(args.manifest)
    for split, entries in partitions.items():
        print(f"{split}: {len(entries)} photos", flush=True)
    if args.audit_only:
        return

    torch.manual_seed(42)
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    loaders = {
        split: DataLoader(EyeDetectionDataset(entries), batch_size=1,
                          shuffle=split == "train", collate_fn=collate)
        for split, entries in partitions.items()
    }
    model = build_detector(pretrained_backbone=True).to(device)
    optimizer = torch.optim.AdamW(model.parameters(), lr=0.0001)
    best_f1 = -1.0
    for epoch in range(1, args.epochs + 1):
        model.train()
        for images, targets in loaders["train"]:
            optimizer.zero_grad()
            losses = model([image.to(device) for image in images], [
                {key: value.to(device) for key, value in target.items()} for target in targets
            ])
            loss = sum(losses.values())
            if not torch.isfinite(loss):
                raise ValueError("Non-finite detector training loss.")
            loss.backward()
            optimizer.step()
        validation = evaluate(model, loaders["val"], device, args.score_threshold)
        tp, fp, fn = (validation["eye"][key] for key in ("tp", "fp", "fn"))
        eye_f1 = 2 * tp / (2 * tp + fp + fn)
        print(f"Epoch {epoch}: validation eye F1 {eye_f1:.3f}", flush=True)
        if eye_f1 > best_f1:
            best_f1 = eye_f1
            best_epoch = epoch
            best_validation = validation
            best_weights = {key: value.detach().cpu().clone()
                            for key, value in model.state_dict().items()}

    model.load_state_dict(best_weights)
    test = evaluate(model, loaders["test"], device, args.score_threshold)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with args.output.open("xb") as file:
        torch.save({
            "model_state_dict": best_weights,
            "classes": list(CLASSES),
            "architecture": "fasterrcnn_mobilenet_v3_large_fpn",
            "image_min_size": 640,
            "image_max_size": 1280,
            "best_epoch": best_epoch,
            "score_threshold": args.score_threshold,
            "validation": best_validation,
            "test": test,
            "manifest_sha256": hashlib.sha256(args.manifest.read_bytes()).hexdigest(),
        }, file)
    print(f"Held-out localization counts at IoU >= 0.5: {test}")


if __name__ == "__main__":
    main()

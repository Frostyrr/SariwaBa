"""Train a candidate validator using reviewed train/val/test CSV partitions.

Does not overwrite the active validator or the existing freshness checkpoint.
Run from backend: python -m ml.train_validator --help
"""
import argparse
import copy
import hashlib
import json
import math
import random
import uuid
from collections import Counter
from pathlib import Path

import torch
from torch import nn
from torch.utils.data import DataLoader
from torchvision import models, transforms

from .predict import DEVICE, MODEL_PATH, _build_eval_transform, predict_image
from .shared_dataset import METADATA_DIR, SariwaBaSharedDataset
from .validator import VALIDATOR_CLASSES, VALIDATOR_V2_CLASSES, VALIDATOR_SCOPES, InputRejectedError, decide_input
from .validator_data import audit_partitions


def score(model, dataset, batch_size):
    model.eval()
    probabilities, targets = [], []
    with torch.inference_mode():
        for images, labels in DataLoader(dataset, batch_size=batch_size):
            probabilities.extend(model(images.to(DEVICE)).softmax(1).cpu().tolist())
            targets.extend(labels.tolist())
    return probabilities, targets


def gate_metrics(probabilities, targets, threshold, classes=VALIDATOR_CLASSES):
    indices = range(len(classes))
    matrix = [[0] * len(classes) for _ in indices]
    accepted, correct = Counter(), Counter()
    prompted = Counter()
    counts = Counter(targets)
    for scores, target in zip(probabilities, targets):
        predicted = max(indices, key=scores.__getitem__)
        matrix[target][predicted] += 1
        # Evaluate content eligibility independently of the user's selected region.
        region = classes[predicted] if predicted in (0, 1) else "eye"
        try:
            decide_input(scores, region, threshold, classes)
            accepted[target] += 1
            correct[target] += int(predicted == target)
        except InputRejectedError as exc:
            if exc.code == "WHOLE_TILAPIA_CLOSE_UP_REQUIRED":
                prompted[target] += 1
    metrics = {
        "confusion_matrix": matrix,
        "class_counts": {classes[k]: counts[k] for k in indices},
        "unsupported_false_accept_rate": accepted[2] / counts[2] if counts[2] else None,
        "supported_correct_accept_rate": {
            classes[k]: correct[k] / counts[k] if counts[k] else None for k in (0, 1)
        },
        "supported_rejection_rate": {
            classes[k]: 1 - correct[k] / counts[k] if counts[k] else None for k in (0, 1)
        },
        "supported_wrong_region_accept_count": sum(accepted[k] - correct[k] for k in (0, 1)),
    }
    if classes == VALIDATOR_V2_CLASSES:
        metrics.update(
            whole_tilapia_prompt_rate=prompted[3] / counts[3] if counts[3] else None,
            whole_tilapia_false_route_rate=accepted[3] / counts[3] if counts[3] else None,
            unsupported_whole_prompt_rate=prompted[2] / counts[2] if counts[2] else None,
        )
    return metrics


def select_threshold(probabilities, targets, max_false_accept_rate, classes=VALIDATOR_CLASSES):
    # Includes boundaries just above observed scores, so a false acceptance can be excluded.
    candidates = {0.5, 1.0}
    for scores in probabilities:
        value = max(scores)
        if value >= 0.5:
            candidates.update([value, min(1.0, math.nextafter(value, 1.0))])
    best = None
    for threshold in sorted(candidates):
        metrics = gate_metrics(probabilities, targets, threshold, classes)
        rates = metrics["supported_correct_accept_rate"]
        far = metrics["unsupported_false_accept_rate"]
        whole_rate = 0
        if classes == VALIDATOR_V2_CLASSES:
            whole_rate = metrics["whole_tilapia_prompt_rate"]
            if not whole_rate or any(
                metrics[key] is None or metrics[key] > max_false_accept_rate
                for key in ("whole_tilapia_false_route_rate", "unsupported_whole_prompt_rate")
            ):
                continue
        if far is not None and far <= max_false_accept_rate and all(rates[k] for k in rates):
            coverage = sum(rates.values()) + whole_rate
            if best is None or coverage > best[0]:
                best = (coverage, threshold, metrics)
    if best is None:
        raise ValueError("No validation threshold meets the false-accept target while accepting both supported regions.")
    return best[1], best[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--metadata-dir", type=Path, default=METADATA_DIR)
    parser.add_argument("--four-class", action="store_true", help="Train using a separate whole-Tilapia manifest.")
    parser.add_argument("--output-dir", type=Path, default=Path("ml/candidates/validator"))
    parser.add_argument("--epochs", type=int, default=15)
    parser.add_argument("--batch-size", type=int, default=32)
    parser.add_argument("--min-eval-per-class", type=int, default=20)
    parser.add_argument("--max-false-accept-rate", type=float, default=0.05)
    parser.add_argument("--freshness-threshold", type=float, default=0.8)
    parser.add_argument("--seed", type=int, default=42)
    args = parser.parse_args()
    if (args.epochs < 1 or args.batch_size < 1 or args.min_eval_per_class < 1
            or not 0 <= args.max_false_accept_rate < 1 or not 0.5 <= args.freshness_threshold <= 1):
        parser.error("Invalid training/evaluation options.")
    if args.output_dir.exists():
        parser.error("Output directory already exists. Use a new candidate directory.")
    if args.four_class and args.metadata_dir.resolve() == METADATA_DIR.resolve():
        parser.error("--four-class requires a separate --metadata-dir.")
    classes = VALIDATOR_V2_CLASSES if args.four_class else VALIDATOR_CLASSES
    indices = range(len(classes))
    counts = audit_partitions(args.metadata_dir, allow_unknown_specimen=args.four_class)
    for split in ("train", "val", "test"):
        minimum = 1 if split == "train" else args.min_eval_per_class
        if any(counts[split][label] < minimum for label in classes):
            raise ValueError(f"{split} needs at least {minimum} reviewed images of every class; found {counts[split]}.")
    random.seed(args.seed)
    torch.manual_seed(args.seed)
    training_transform = transforms.Compose([
        transforms.Resize((224, 224)), transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(10),
        transforms.ColorJitter(brightness=0.15, contrast=0.15, saturation=0.15),
        transforms.ToTensor(), transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])
    datasets = {
        split: SariwaBaSharedDataset("validator_v2" if args.four_class else "validator", split=split,
            transform=training_transform if split == "train" else _build_eval_transform(224),
            metadata_dir=args.metadata_dir)
        for split in ("train", "val", "test")
    }
    model = models.mobilenet_v3_small(weights=models.MobileNet_V3_Small_Weights.DEFAULT)
    for parameter in model.features.parameters():
        parameter.requires_grad = False
    model.classifier[3] = nn.Linear(model.classifier[3].in_features, len(classes))
    model.to(DEVICE)
    optimizer = torch.optim.Adam(model.classifier.parameters(), lr=0.001)
    weights = torch.tensor([1 / counts["train"][label] for label in classes], device=DEVICE)
    criterion = nn.CrossEntropyLoss(weight=weights)
    best_score, best_state = -1, None
    for epoch in range(args.epochs):
        model.train()
        model.features.eval()  # Keep frozen backbone batch-normalization statistics fixed.
        for images, labels in DataLoader(datasets["train"], batch_size=args.batch_size, shuffle=True):
            optimizer.zero_grad()
            loss = criterion(model(images.to(DEVICE)), labels.to(DEVICE))
            loss.backward()
            optimizer.step()
        probabilities, targets = score(model, datasets["val"], args.batch_size)
        matrix = gate_metrics(probabilities, targets, 0.5, classes)["confusion_matrix"]
        macro_recall = sum(matrix[k][k] / sum(matrix[k]) for k in indices) / len(classes)
        print(f"Epoch {epoch+1}: validation macro recall {macro_recall:.4f}", flush=True)
        if macro_recall > best_score:
            best_score, best_state = macro_recall, copy.deepcopy(model.state_dict())
    model.load_state_dict(best_state)
    probabilities, targets = score(model, datasets["val"], args.batch_size)
    threshold, validation_metrics = select_threshold(probabilities, targets, args.max_false_accept_rate, classes)
    test_probabilities, test_targets = score(model, datasets["test"], args.batch_size)
    test_metrics = gate_metrics(test_probabilities, test_targets, threshold, classes)
    # End-to-end freshness evaluation on supported test inputs accepted with the true region.
    freshness_counts = Counter()
    truth = {}
    if not args.four_class:
        freshness_labels = SariwaBaSharedDataset("freshness", split="test", transform=None, metadata_dir=args.metadata_dir)
        truth = {path: freshness_labels.classes[label] for path, label in freshness_labels.samples}
    for (path, target), scores in zip(datasets["test"].samples, test_probabilities):
        if args.four_class or target == 2:
            continue
        freshness_counts["supported_total"] += 1
        try:
            decide_input(scores, VALIDATOR_CLASSES[target], threshold)
        except InputRejectedError:
            continue
        if path not in truth:
            raise ValueError(f"Missing freshness test label: {path}")
        result = predict_image(path)
        freshness_counts["passed_gate"] += 1
        if result["confidence"] < args.freshness_threshold:
            freshness_counts["freshness_uncertain"] += 1
        else:
            freshness_counts["classified"] += 1
            freshness_counts["correct"] += int(result["raw_label"] == truth[path])
    hashes = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in args.metadata_dir.glob("*.csv")}
    report = {"validation": validation_metrics, "test": test_metrics,
        "end_to_end_test": dict(freshness_counts), "freshness_threshold": args.freshness_threshold,
        "acceptance_threshold": threshold, "target_false_accept_rate": args.max_false_accept_rate,
        "manifest_sha256": hashes, "seed": args.seed,
        "min_eval_per_class": args.min_eval_per_class,
        "freshness_checkpoint_sha256": None if args.four_class else hashlib.sha256(MODEL_PATH.read_bytes()).hexdigest(),
        "end_to_end_status": "not_evaluated_no_freshness_ground_truth" if args.four_class else "exploratory_existing_freshness_checkpoint_split_unknown",
        "limitations": "Validator uses reviewed held-out partitions. Existing freshness checkpoint training membership is unknown, so its end-to-end scores are exploratory, not independent held-out performance. No independent species or food-safety verification. Review negative-category diversity and specimen provenance before deployment."}
    args.output_dir.mkdir(parents=True)
    (args.output_dir / "evaluation.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    checkpoint = {"model_state_dict": {k: v.cpu() for k, v in best_state.items()},
        "classes": classes, "image_size": 224, "validation_scope": VALIDATOR_SCOPES[len(classes)],
        "threshold_source": "validation_split", "acceptance_threshold": threshold,
        "model_version": f"validator-{uuid.uuid4().hex[:12]}", "evaluation": report}
    torch.save(checkpoint, args.output_dir / "sariwaba_validator.pth")
    print(f"Candidate and report saved to {args.output_dir}. Active models were not replaced.")


if __name__ == "__main__":
    main()

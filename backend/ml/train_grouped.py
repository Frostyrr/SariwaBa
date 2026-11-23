import argparse
import csv
import hashlib
from pathlib import Path
from collections import Counter, defaultdict
import random

from PIL import Image, ImageOps
import torch
from torch import nn, optim
from torch.utils.data import ConcatDataset, DataLoader, Dataset, Subset
from torchvision import datasets, models, transforms
import re


# ============================================================
# CONFIG
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "datasets" / "tilapia"

MODEL_DIR = BASE_DIR / "ml" / "models"
ACTIVE_CHECKPOINT = MODEL_DIR / "sariwaba_mobilenetv3_best.pth"

parser = argparse.ArgumentParser(description="Train a grouped Model B freshness classifier.")
parser.add_argument("--manifest", type=Path, help="Unified multi-source CSV with image_path,region,freshness_label,group_key,split.")
parser.add_argument("--local-manifest", type=Path, help="Local training supplements CSV.")
parser.add_argument("--output", type=Path, help="Path to a new candidate checkpoint.")
parser.add_argument("--epochs", type=int, default=20)
parser.add_argument("--batch-size", type=int, default=32)
parser.add_argument("--unfreeze-from", type=int, default=4,
                    help="First MobileNetV3 features block index to unfreeze (0=all, -1=freeze all).")
parser.add_argument("--backbone-lr", type=float, default=2e-4)
parser.add_argument("--head-lr", type=float, default=1e-3)
parser.add_argument("--weight-decay", type=float, default=1e-4)
parser.add_argument("--label-smoothing", type=float, default=0.05)
args = parser.parse_args()
if args.epochs < 1 or args.batch_size < 1:
    parser.error("--epochs and --batch-size must be positive.")
if args.manifest and args.local_manifest:
    parser.error("Use either --manifest or --local-manifest, not both.")
if (args.local_manifest or args.manifest) and args.output is None:
    parser.error("--manifest / --local-manifest requires a separate --output checkpoint.")
checkpoint_path = args.output.resolve() if args.output else ACTIVE_CHECKPOINT
if args.output and (checkpoint_path.exists() or checkpoint_path == ACTIVE_CHECKPOINT.resolve()):
    parser.error("--output must be a new path outside the active checkpoint.")
checkpoint_path.parent.mkdir(parents=True, exist_ok=True)

IMAGE_SIZE = 224
BATCH_SIZE = args.batch_size
EPOCHS = args.epochs
LEARNING_RATE = args.head_lr

RANDOM_SEED = 42

# Consecutive frames in NonFresh folders are grouped together.
# 50 means images 0001-0050 stay together, etc.
BLOCK_SIZE = 50

DEVICE = torch.device(
    "cuda" if torch.cuda.is_available() else "cpu"
)

random.seed(RANDOM_SEED)
torch.manual_seed(RANDOM_SEED)
if torch.cuda.is_available():
    torch.cuda.manual_seed_all(RANDOM_SEED)


print("=" * 60)
print("SariwaBa Grouped Fish Freshness Training")
print("=" * 60)

print(f"Device: {DEVICE}")
print(f"Dataset: {args.manifest if args.manifest else DATA_DIR}")


# ============================================================
# TRANSFORMS
# ============================================================

train_transform = transforms.Compose([
    transforms.RandomResizedCrop(
        IMAGE_SIZE,
        scale=(0.65, 1.0),
        ratio=(0.8, 1.25),
    ),

    transforms.RandomHorizontalFlip(),

    transforms.RandomRotation(20),

    transforms.ColorJitter(
        brightness=0.20,
        contrast=0.20,
        saturation=0.20,
        hue=0.02,
    ),

    transforms.RandomApply(
        [transforms.GaussianBlur(kernel_size=3)],
        p=0.15,
    ),

    transforms.ToTensor(),

    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])


eval_transform = transforms.Compose([
    transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),

    transforms.ToTensor(),

    transforms.Normalize(
        mean=[0.485, 0.456, 0.406],
        std=[0.229, 0.224, 0.225],
    ),
])


# ============================================================
# LOAD DATASET
# ============================================================

base_dataset = datasets.ImageFolder(
    root=DATA_DIR
)

print("\nClasses:")
print(base_dataset.classes)

print("\nClass mapping:")
print(base_dataset.class_to_idx)

print(f"\nTotal images: {len(base_dataset)}")


# ============================================================
# CREATE CAPTURE GROUP
# ============================================================

def create_group_key(path_string):
    path = Path(path_string)

    parts = path.parts

    # --------------------------------------------------------
    # FRESH
    # --------------------------------------------------------
    #
    # Example:
    # Fresh/Day 1/Eyes/1_Eyes/0235.jpg
    #
    # Keep the entire 1_Eyes directory together.
    #
    if "Fresh" in parts:

        parent = path.parent

        return f"Fresh::{parent}"


    # --------------------------------------------------------
    # NONFRESH
    # --------------------------------------------------------
    #
    # NonFresh does not have specimen-number directories.
    # Therefore group neighboring numbered frames into blocks.
    #
    # Example:
    # 0001-0050 -> block 0
    # 0051-0100 -> block 1
    # etc.
    #
    if "NonFresh" in parts:

        match = re.match(r"(\d+)", path.stem)

        if match:
            image_number = int(match.group(1))
        else:
            image_number = 0

        block_number = image_number // BLOCK_SIZE

        parent = path.parent

        return (
            f"NonFresh::{parent}::"
            f"block_{block_number}"
        )


    return str(path.parent)


# ============================================================
# COLLECT GROUPS BY CLASS
# ============================================================

groups_by_class = defaultdict(
    lambda: defaultdict(list)
)


for index, (path, class_index) in enumerate(
    base_dataset.samples
):

    group_key = create_group_key(path)

    groups_by_class[class_index][group_key].append(
        index
    )


print("\nDetected grouped sequences:")

for class_index, class_name in enumerate(
    base_dataset.classes
):

    groups = groups_by_class[class_index]

    print(
        f"{class_name}: "
        f"{len(groups)} groups"
    )


# ============================================================
# SPLIT GROUPS
# ============================================================

train_indices = []
val_indices = []
test_indices = []


for class_index in range(
    len(base_dataset.classes)
):

    groups = list(
        groups_by_class[class_index].keys()
    )

    random.shuffle(groups)

    number_of_groups = len(groups)

    train_count = max(
        1,
        int(number_of_groups * 0.70)
    )

    val_count = max(
        1,
        int(number_of_groups * 0.15)
    )


    # Ensure at least one test group
    if train_count + val_count >= number_of_groups:

        train_count = max(
            1,
            number_of_groups - 2
        )

        val_count = 1


    train_groups = groups[
        :train_count
    ]

    val_groups = groups[
        train_count:
        train_count + val_count
    ]

    test_groups = groups[
        train_count + val_count:
    ]


    for group in train_groups:

        train_indices.extend(
            groups_by_class[class_index][group]
        )


    for group in val_groups:

        val_indices.extend(
            groups_by_class[class_index][group]
        )


    for group in test_groups:

        test_indices.extend(
            groups_by_class[class_index][group]
        )


print("\nGrouped dataset split:")

print(
    f"Training images:   "
    f"{len(train_indices)}"
)

print(
    f"Validation images: "
    f"{len(val_indices)}"
)

print(
    f"Testing images:    "
    f"{len(test_indices)}"
)


# ============================================================
# VERIFY NO GROUP LEAKAGE
# ============================================================

def get_groups(indices):

    result = set()

    for index in indices:

        path, _ = base_dataset.samples[index]

        result.add(
            create_group_key(path)
        )

    return result


train_groups = get_groups(train_indices)
val_groups = get_groups(val_indices)
test_groups = get_groups(test_indices)


assert train_groups.isdisjoint(
    val_groups
)

assert train_groups.isdisjoint(
    test_groups
)

assert val_groups.isdisjoint(
    test_groups
)


print(
    "\nGroup leakage check: PASSED"
)


# ============================================================
# DATASETS
# ============================================================

train_full_dataset = datasets.ImageFolder(
    DATA_DIR,
    transform=train_transform,
)

eval_full_dataset = datasets.ImageFolder(
    DATA_DIR,
    transform=eval_transform,
)


train_dataset = Subset(
    train_full_dataset,
    train_indices,
)

val_dataset = Subset(
    eval_full_dataset,
    val_indices,
)

test_dataset = Subset(
    eval_full_dataset,
    test_indices,
)


class LocalFreshnessDataset(Dataset):
    def __init__(self, samples, transform):
        self.samples = samples
        self.transform = transform

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, index):
        path, target = self.samples[index]
        with Image.open(path) as source:
            source.draft("RGB", (512, 512))
            image = ImageOps.exif_transpose(source).convert("RGB")
        return self.transform(image), target


local_samples = []
local_metadata = {}
if args.manifest:
    datasets_root = (BASE_DIR / "datasets").resolve()
    split_samples = {"train": [], "val": [], "test": []}
    group_splits = defaultdict(set)
    seen = set()
    counts_by_split = Counter()
    with args.manifest.open(newline="", encoding="utf-8-sig") as manifest:
        for row in csv.DictReader(manifest):
            image = (BASE_DIR / row["image_path"]).resolve()
            region = row["region"].strip()
            label = row["freshness_label"].strip()
            group = row["group_key"].strip()
            split = row["split"].strip()
            if (
                not image.is_relative_to(datasets_root) or not image.is_file()
                or image in seen or region not in {"eye", "gill"}
                or label not in base_dataset.class_to_idx
                or not group or split not in split_samples
            ):
                parser.error(f"Invalid manifest entry for {row['image_path']}.")
            seen.add(image)
            group_splits[group].add(split)
            split_samples[split].append((image, base_dataset.class_to_idx[label]))
            counts_by_split[(split, region, label)] += 1
    leaked_groups = [g for g, ss in group_splits.items() if len(ss) > 1]
    if leaked_groups:
        parser.error(f"Group leakage across splits in manifest: {leaked_groups[:5]}")
    for s in ("train", "val", "test"):
        if not split_samples[s]:
            parser.error(f"Manifest split '{s}' is empty.")
    train_dataset = LocalFreshnessDataset(split_samples["train"], train_transform)
    val_dataset = LocalFreshnessDataset(split_samples["val"], eval_transform)
    test_dataset = LocalFreshnessDataset(split_samples["test"], eval_transform)
    train_targets = [target for _, target in split_samples["train"]]
    local_metadata = {
        "manifest_sha256": hashlib.sha256(args.manifest.read_bytes()).hexdigest(),
        "split_counts": {f"{s}:{r}:{l}": c for (s, r, l), c in sorted(counts_by_split.items())},
    }
    print(f"Unified manifest loaded: {local_metadata['split_counts']}", flush=True)
elif args.local_manifest:
    local_root = (BASE_DIR / "datasets" / "local_collection").resolve()
    counts_by_region = Counter()
    groups = set()
    seen = set()
    with args.local_manifest.open(newline="", encoding="utf-8-sig") as manifest:
        for row in csv.DictReader(manifest):
            image = (BASE_DIR / row["image_path"]).resolve()
            region, label = row["region"], row["freshness_label"]
            group, source = row["group_key"].strip(), row["label_source"].strip()
            if (
                not image.is_relative_to(local_root) or not image.is_file()
                or image in seen or region not in {"eye", "gill"}
                or label not in base_dataset.class_to_idx
                or not group or not source or row["split"] != "train"
            ):
                parser.error(f"Invalid local training entry for {row['image_path']}.")
            seen.add(image)
            groups.add(group)
            local_samples.append((image, base_dataset.class_to_idx[label]))
            counts_by_region[(region, label, source)] += 1
    if not local_samples:
        parser.error("The local manifest contains no training photos.")
    train_dataset = ConcatDataset([
        train_dataset, LocalFreshnessDataset(local_samples, train_transform),
    ])
    local_metadata = {
        "manifest_sha256": hashlib.sha256(args.local_manifest.read_bytes()).hexdigest(),
        "groups": sorted(groups),
        "counts": [
            {"region": region, "label": label, "source": source, "count": count}
            for (region, label, source), count in sorted(counts_by_region.items())
        ],
    }
    print(f"Local training supplements: {local_metadata}", flush=True)


train_loader = DataLoader(
    train_dataset,
    batch_size=BATCH_SIZE,
    shuffle=True,
)

val_loader = DataLoader(
    val_dataset,
    batch_size=BATCH_SIZE,
    shuffle=False,
)

test_loader = DataLoader(
    test_dataset,
    batch_size=BATCH_SIZE,
    shuffle=False,
)


# ============================================================
# CLASS WEIGHTS
# ============================================================

if not args.manifest:
    train_targets = [
        base_dataset.samples[index][1]
        for index in train_indices
    ]
    train_targets.extend(target for _, target in local_samples)

counts = Counter(train_targets)

number_of_classes = len(
    base_dataset.classes
)

total_train = len(train_targets)


weights = []

for class_index in range(
    number_of_classes
):

    count = counts[class_index]

    weight = (
        total_train /
        (
            number_of_classes
            * count
        )
    )

    weights.append(weight)


class_weights = torch.tensor(
    weights,
    dtype=torch.float32,
).to(DEVICE)


print("\nTraining class counts:")

for class_index, class_name in enumerate(
    base_dataset.classes
):

    print(
        f"{class_name}: "
        f"{counts[class_index]}"
    )


print("\nClass weights:")
print(class_weights)


# ============================================================
# MODEL
# ============================================================

weights = (
    models.MobileNet_V3_Small_Weights.DEFAULT
)


model = models.mobilenet_v3_small(
    weights=weights
)


num_blocks = len(model.features)
freeze_limit = (
    num_blocks
    if args.unfreeze_from < 0
    else min(args.unfreeze_from, num_blocks)
)
for block_idx, block in enumerate(model.features):
    trainable = block_idx >= freeze_limit
    for parameter in block.parameters():
        parameter.requires_grad = trainable


num_features = (
    model.classifier[3].in_features
)


model.classifier[3] = nn.Linear(
    num_features,
    number_of_classes,
)


model = model.to(DEVICE)


criterion = nn.CrossEntropyLoss(
    weight=class_weights,
    label_smoothing=args.label_smoothing,
)
eval_criterion = nn.CrossEntropyLoss(
    weight=class_weights,
)

backbone_params = [
    p for p in model.features.parameters() if p.requires_grad
]
param_groups = [
    {"params": list(model.classifier.parameters()), "lr": args.head_lr},
]
if backbone_params:
    param_groups.append(
        {"params": backbone_params, "lr": args.backbone_lr}
    )

optimizer = optim.AdamW(
    param_groups,
    weight_decay=args.weight_decay,
)
scheduler = optim.lr_scheduler.CosineAnnealingLR(
    optimizer,
    T_max=EPOCHS,
    eta_min=1e-6,
)

print(
    f"\nUnfreeze from block: {freeze_limit}/{num_blocks} | "
    f"backbone_lr={args.backbone_lr} | head_lr={args.head_lr} | "
    f"label_smoothing={args.label_smoothing}",
    flush=True,
)


# ============================================================
# TRAIN
# ============================================================

best_key = None
best_val_accuracy = 0.0
best_val_macro_f1 = 0.0
best_val_loss = float("inf")


def compute_macro_f1(actual, predicted, num_classes):
    f1s = []
    for c in range(num_classes):
        tp = sum(1 for a, p in zip(actual, predicted) if a == c and p == c)
        fp = sum(1 for a, p in zip(actual, predicted) if a != c and p == c)
        fn = sum(1 for a, p in zip(actual, predicted) if a == c and p != c)
        denom = 2 * tp + fp + fn
        f1s.append((2 * tp / denom) if denom > 0 else 0.0)
    return sum(f1s) / num_classes


for epoch in range(EPOCHS):

    model.train()
    for block_idx in range(freeze_limit):
        model.features[block_idx].eval()

    running_loss = 0.0

    correct = 0
    total = 0


    for images, labels in train_loader:

        images = images.to(DEVICE)
        labels = labels.to(DEVICE)

        optimizer.zero_grad(set_to_none=True)

        outputs = model(images)

        loss = criterion(
            outputs,
            labels
        )

        loss.backward()

        optimizer.step()


        running_loss += loss.item()


        _, predictions = torch.max(
            outputs,
            1
        )


        total += labels.size(0)

        correct += (
            predictions == labels
        ).sum().item()


    scheduler.step()
    train_accuracy = (
        100 * correct / total
    )


    # ========================================================
    # VALIDATION
    # ========================================================

    model.eval()

    val_correct = 0
    val_total = 0
    val_loss_sum = 0.0
    val_actual = []
    val_predicted = []


    with torch.no_grad():

        for images, labels in val_loader:

            images = images.to(DEVICE)
            labels = labels.to(DEVICE)

            outputs = model(images)
            v_loss = eval_criterion(outputs, labels)
            val_loss_sum += v_loss.item() * labels.size(0)


            _, predictions = torch.max(
                outputs,
                1
            )


            val_total += labels.size(0)

            val_correct += (
                predictions == labels
            ).sum().item()
            val_actual.extend(labels.cpu().tolist())
            val_predicted.extend(predictions.cpu().tolist())


    val_accuracy = (
        100
        * val_correct
        / val_total
    )
    val_loss = val_loss_sum / max(1, val_total)
    val_macro_f1 = compute_macro_f1(
        val_actual,
        val_predicted,
        number_of_classes,
    )


    average_loss = (
        running_loss /
        len(train_loader)
    )


    print(
        f"\nEpoch [{epoch + 1}/{EPOCHS}] | "
        f"Train Loss: {average_loss:.4f} | Train Acc: {train_accuracy:.2f}% | "
        f"Val Loss: {val_loss:.4f} | Val Acc: {val_accuracy:.2f}% | "
        f"Val Macro-F1: {val_macro_f1:.4f}",
        flush=True,
    )


    # ========================================================
    # SAVE BEST MODEL (Macro-F1, then Accuracy, then lowest Val Loss)
    # ========================================================

    selection_key = (
        round(val_macro_f1, 6),
        round(val_accuracy, 6),
        -val_loss,
    )
    if best_key is None or selection_key > best_key:

        best_key = selection_key
        best_val_accuracy = val_accuracy
        best_val_macro_f1 = val_macro_f1
        best_val_loss = val_loss


        checkpoint = {

            "model_state_dict":
                {k: v.detach().cpu().clone() for k, v in model.state_dict().items()},

            "classes":
                base_dataset.classes,

            "class_to_idx":
                base_dataset.class_to_idx,

            "image_size":
                IMAGE_SIZE,

            "validation_accuracy":
                best_val_accuracy,
            "validation_macro_f1":
                best_val_macro_f1,
            "validation_loss":
                best_val_loss,
            "unfreeze_from":
                freeze_limit,

            "split_method":
                "unified_manifest_split" if args.manifest else "grouped_capture_split",
            "local_training": local_metadata,
            "best_epoch": epoch + 1,
        }


        torch.save(
            checkpoint,

            checkpoint_path,
        )


        print(
            "Best model saved! "
            f"Epoch {epoch + 1} | Val Macro-F1: {best_val_macro_f1:.4f} | "
            f"Val Acc: {best_val_accuracy:.2f}% | Val Loss: {best_val_loss:.4f}",
            flush=True,
        )


# ============================================================
# TEST BEST MODEL
# ============================================================

print("\n" + "=" * 60)
print("Testing best grouped model")
print("=" * 60)


checkpoint = torch.load(

    checkpoint_path,

    map_location=DEVICE,

    weights_only=False,
)


model.load_state_dict(
    checkpoint["model_state_dict"]
)


model.eval()

test_correct = 0
test_total = 0


with torch.no_grad():

    for images, labels in test_loader:

        images = images.to(DEVICE)
        labels = labels.to(DEVICE)

        outputs = model(images)

        _, predictions = torch.max(
            outputs,
            1
        )


        test_total += labels.size(0)

        test_correct += (
            predictions == labels
        ).sum().item()


test_accuracy = (
    100
    * test_correct
    / test_total
)


print(
    f"\nBest validation accuracy: "
    f"{best_val_accuracy:.2f}%"
)

print(
    f"Final test accuracy: "
    f"{test_accuracy:.2f}%"
)

print("\nTraining complete.")

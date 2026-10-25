from pathlib import Path
from collections import Counter, defaultdict
import random
import statistics
import csv

import numpy as np
import matplotlib.pyplot as plt

import torch
from torch import nn, optim
from torch.utils.data import DataLoader, Subset
from torchvision import datasets, models, transforms
import re

from sklearn.metrics import (
    confusion_matrix,
    classification_report,
)


# ============================================================
# CONFIG
# ============================================================

BASE_DIR = Path(__file__).resolve().parent.parent

DATA_DIR = BASE_DIR / "datasets" / "tilapia"

RESULTS_DIR = BASE_DIR / "ml" / "results"
RESULTS_DIR.mkdir(
    parents=True,
    exist_ok=True,
)

IMAGE_SIZE = 224
BATCH_SIZE = 16
EPOCHS = 5
LEARNING_RATE = 0.001

NUM_FOLDS = 5
RANDOM_SEED = 42

# For NonFresh sequential images.
# Images are grouped into blocks so nearby frames do not leak
# between training and validation.
BLOCK_SIZE = 50


DEVICE = torch.device(
    "cuda"
    if torch.cuda.is_available()
    else "cpu"
)


# ============================================================
# RANDOM SEEDS
# ============================================================

random.seed(RANDOM_SEED)
np.random.seed(RANDOM_SEED)
torch.manual_seed(RANDOM_SEED)

if torch.cuda.is_available():
    torch.cuda.manual_seed_all(
        RANDOM_SEED
    )


# ============================================================
# START
# ============================================================

print("=" * 70)
print("SariwaBa 5-Fold Grouped Cross-Validation")
print("=" * 70)

print(f"Device: {DEVICE}")
print(f"Dataset: {DATA_DIR}")
print(f"Results folder: {RESULTS_DIR}")


# ============================================================
# TRANSFORMS
# ============================================================

train_transform = transforms.Compose([
    transforms.Resize(
        (IMAGE_SIZE, IMAGE_SIZE)
    ),

    transforms.RandomHorizontalFlip(),

    transforms.RandomRotation(
        10
    ),

    transforms.ColorJitter(
        brightness=0.15,
        contrast=0.15,
        saturation=0.15,
    ),

    transforms.ToTensor(),

    transforms.Normalize(
        mean=[
            0.485,
            0.456,
            0.406,
        ],
        std=[
            0.229,
            0.224,
            0.225,
        ],
    ),
])


eval_transform = transforms.Compose([
    transforms.Resize(
        (IMAGE_SIZE, IMAGE_SIZE)
    ),

    transforms.ToTensor(),

    transforms.Normalize(
        mean=[
            0.485,
            0.456,
            0.406,
        ],
        std=[
            0.229,
            0.224,
            0.225,
        ],
    ),
])


# ============================================================
# LOAD BASE DATASET
# ============================================================

base_dataset = datasets.ImageFolder(
    root=DATA_DIR
)


print("\nClasses:")
print(base_dataset.classes)

print("\nClass mapping:")
print(base_dataset.class_to_idx)

print(
    f"\nTotal images: "
    f"{len(base_dataset)}"
)


# ============================================================
# CREATE GROUP KEY
# ============================================================

def create_group_key(path_string):
    path = Path(path_string)

    parts = path.parts

    # --------------------------------------------------------
    # FRESH
    #
    # Fresh images are already stored inside specimen/capture
    # folders such as:
    #
    # Fresh/Day 1/Eyes/1_Eyes/
    #
    # Keep the whole leaf folder together.
    # --------------------------------------------------------

    if "Fresh" in parts:

        return (
            f"Fresh::{path.parent}"
        )


    # --------------------------------------------------------
    # NONFRESH
    #
    # NonFresh images are sequential frames stored in broader
    # folders. Divide them into blocks of 50 sequential images.
    # --------------------------------------------------------

    if "NonFresh" in parts:

        match = re.match(r"(\d+)", path.stem)

        if match:
            image_number = int(match.group(1))
        else:
            image_number = 0


        block_number = (
            image_number
            // BLOCK_SIZE
        )


        return (
            f"NonFresh::"
            f"{path.parent}::"
            f"block_{block_number}"
        )


    # Fallback
    return str(
        path.parent
    )


# ============================================================
# COLLECT GROUPS BY CLASS
# ============================================================

groups_by_class = defaultdict(
    lambda: defaultdict(list)
)


for index, (
    path,
    class_index,
) in enumerate(
    base_dataset.samples
):

    group_key = create_group_key(
        path
    )


    groups_by_class[
        class_index
    ][
        group_key
    ].append(
        index
    )


print(
    "\nDetected grouped sequences:"
)


for class_index, class_name in enumerate(
    base_dataset.classes
):

    number_of_groups = len(
        groups_by_class[
            class_index
        ]
    )

    print(
        f"{class_name}: "
        f"{number_of_groups} groups"
    )


# ============================================================
# BUILD 5 GROUPED FOLDS
# ============================================================

fold_validation_indices = [
    []
    for _ in range(NUM_FOLDS)
]


for class_index in range(
    len(base_dataset.classes)
):

    groups = list(
        groups_by_class[
            class_index
        ].keys()
    )


    group_randomizer = random.Random(
        RANDOM_SEED
        + class_index
    )


    group_randomizer.shuffle(
        groups
    )


    for position, group_key in enumerate(
        groups
    ):

        fold_index = (
            position
            % NUM_FOLDS
        )


        fold_validation_indices[
            fold_index
        ].extend(
            groups_by_class[
                class_index
            ][
                group_key
            ]
        )


all_indices = set(
    range(
        len(base_dataset)
    )
)


# ============================================================
# PRINT FOLD SIZES
# ============================================================

print("\nFold sizes:")


for fold_index in range(
    NUM_FOLDS
):

    validation_indices = set(
        fold_validation_indices[
            fold_index
        ]
    )


    training_indices = (
        all_indices
        - validation_indices
    )


    print(
        f"Fold {fold_index + 1}: "
        f"Train={len(training_indices)}, "
        f"Validation={len(validation_indices)}"
    )


# ============================================================
# VERIFY GROUP LEAKAGE
# ============================================================

def get_groups(indices):

    result = set()


    for index in indices:

        path, _ = (
            base_dataset.samples[
                index
            ]
        )


        result.add(
            create_group_key(
                path
            )
        )


    return result


for fold_index in range(
    NUM_FOLDS
):

    validation_indices = set(
        fold_validation_indices[
            fold_index
        ]
    )


    training_indices = (
        all_indices
        - validation_indices
    )


    train_groups = get_groups(
        training_indices
    )


    validation_groups = get_groups(
        validation_indices
    )


    assert train_groups.isdisjoint(
        validation_groups
    ), (
        f"Group leakage detected "
        f"in Fold {fold_index + 1}"
    )


print(
    "\nGroup leakage check: PASSED"
)


# ============================================================
# DATASETS WITH DIFFERENT TRANSFORMS
# ============================================================

train_full_dataset = datasets.ImageFolder(
    root=DATA_DIR,
    transform=train_transform,
)


eval_full_dataset = datasets.ImageFolder(
    root=DATA_DIR,
    transform=eval_transform,
)


# ============================================================
# RESULT STORAGE
# ============================================================

fold_accuracies = []

all_true_labels = []
all_predictions = []


# ============================================================
# CROSS-VALIDATION LOOP
# ============================================================

for fold_index in range(
    NUM_FOLDS
):

    print(
        "\n"
        + "=" * 70
    )

    print(
        f"FOLD "
        f"{fold_index + 1}/"
        f"{NUM_FOLDS}"
    )

    print(
        "=" * 70
    )


    # --------------------------------------------------------
    # SPLIT INDICES
    # --------------------------------------------------------

    validation_indices = list(
        fold_validation_indices[
            fold_index
        ]
    )


    validation_index_set = set(
        validation_indices
    )


    training_indices = list(
        all_indices
        - validation_index_set
    )


    # --------------------------------------------------------
    # SUBSETS
    # --------------------------------------------------------

    train_dataset = Subset(
        train_full_dataset,
        training_indices,
    )


    validation_dataset = Subset(
        eval_full_dataset,
        validation_indices,
    )


    # --------------------------------------------------------
    # DATALOADERS
    # --------------------------------------------------------

    train_loader = DataLoader(
        train_dataset,
        batch_size=BATCH_SIZE,
        shuffle=True,
    )


    validation_loader = DataLoader(
        validation_dataset,
        batch_size=BATCH_SIZE,
        shuffle=False,
    )


    # ========================================================
    # CLASS WEIGHTS
    # ========================================================

    train_targets = [
        base_dataset.samples[
            index
        ][1]
        for index
        in training_indices
    ]


    class_counts = Counter(
        train_targets
    )


    number_of_classes = len(
        base_dataset.classes
    )


    total_training_images = len(
        train_targets
    )


    class_weights = []


    for class_index in range(
        number_of_classes
    ):

        class_count = class_counts[
            class_index
        ]


        weight = (
            total_training_images
            /
            (
                number_of_classes
                * class_count
            )
        )


        class_weights.append(
            weight
        )


    class_weights = torch.tensor(
        class_weights,
        dtype=torch.float32,
    ).to(
        DEVICE
    )


    print(
        "\nTraining class counts:"
    )


    for class_index, class_name in enumerate(
        base_dataset.classes
    ):

        print(
            f"{class_name}: "
            f"{class_counts[class_index]}"
        )


    print(
        f"Class weights: "
        f"{class_weights}"
    )


    # ========================================================
    # CREATE NEW MODEL FOR THIS FOLD
    # ========================================================

    pretrained_weights = (
        models
        .MobileNet_V3_Small_Weights
        .DEFAULT
    )


    model = (
        models.mobilenet_v3_small(
            weights=pretrained_weights
        )
    )


    # Freeze feature extractor
    for parameter in (
        model.features.parameters()
    ):

        parameter.requires_grad = (
            False
        )


    number_of_features = (
        model.classifier[
            3
        ].in_features
    )


    model.classifier[3] = nn.Linear(
        number_of_features,
        number_of_classes,
    )


    model = model.to(
        DEVICE
    )


    # ========================================================
    # LOSS + OPTIMIZER
    # ========================================================

    criterion = nn.CrossEntropyLoss(
        weight=class_weights
    )


    optimizer = optim.Adam(
        model.classifier.parameters(),
        lr=LEARNING_RATE,
    )


    # ========================================================
    # TRAIN MODEL
    # ========================================================

    best_validation_accuracy = (
        -1.0
    )

    best_state = None


    for epoch in range(
        EPOCHS
    ):

        # ----------------------------------------------------
        # TRAIN
        # ----------------------------------------------------

        model.train()


        running_loss = 0.0
        training_correct = 0
        training_total = 0


        for images, labels in (
            train_loader
        ):

            images = images.to(
                DEVICE
            )


            labels = labels.to(
                DEVICE
            )


            optimizer.zero_grad()


            outputs = model(
                images
            )


            loss = criterion(
                outputs,
                labels
            )


            loss.backward()


            optimizer.step()


            running_loss += (
                loss.item()
            )


            _, predictions = torch.max(
                outputs,
                1
            )


            training_total += (
                labels.size(0)
            )


            training_correct += (
                predictions
                == labels
            ).sum().item()


        training_accuracy = (
            100
            * training_correct
            / training_total
        )


        average_training_loss = (
            running_loss
            / len(train_loader)
        )


        # ----------------------------------------------------
        # VALIDATION
        # ----------------------------------------------------

        model.eval()


        validation_correct = 0
        validation_total = 0


        with torch.no_grad():

            for images, labels in (
                validation_loader
            ):

                images = images.to(
                    DEVICE
                )


                labels = labels.to(
                    DEVICE
                )


                outputs = model(
                    images
                )


                _, predictions = (
                    torch.max(
                        outputs,
                        1
                    )
                )


                validation_total += (
                    labels.size(0)
                )


                validation_correct += (
                    predictions
                    == labels
                ).sum().item()


        validation_accuracy = (
            100
            * validation_correct
            / validation_total
        )


        print(
            f"Epoch "
            f"[{epoch + 1}/{EPOCHS}] "
            f"Loss: "
            f"{average_training_loss:.4f} "
            f"Train Acc: "
            f"{training_accuracy:.2f}% "
            f"Val Acc: "
            f"{validation_accuracy:.2f}%"
        )


        # ----------------------------------------------------
        # SAVE BEST STATE IN MEMORY
        # ----------------------------------------------------

        if (
            validation_accuracy
            > best_validation_accuracy
        ):

            best_validation_accuracy = (
                validation_accuracy
            )


            best_state = {
                key: value
                .detach()
                .cpu()
                .clone()

                for key, value
                in model.state_dict().items()
            }


    # ========================================================
    # LOAD BEST MODEL FOR THIS FOLD
    # ========================================================

    if best_state is None:

        raise RuntimeError(
            f"No best model state "
            f"was created for "
            f"Fold {fold_index + 1}."
        )


    model.load_state_dict(
        best_state
    )


    model = model.to(
        DEVICE
    )


    model.eval()


    # ========================================================
    # FINAL PREDICTIONS FOR THIS FOLD
    # ========================================================

    fold_true_labels = []
    fold_predictions = []


    with torch.no_grad():

        for images, labels in (
            validation_loader
        ):

            images = images.to(
                DEVICE
            )


            outputs = model(
                images
            )


            _, predictions = (
                torch.max(
                    outputs,
                    1
                )
            )


            fold_true_labels.extend(
                labels.tolist()
            )


            fold_predictions.extend(
                predictions
                .cpu()
                .tolist()
            )


    # ========================================================
    # FOLD ACCURACY
    # ========================================================

    fold_correct = sum(
        true_label
        == predicted_label

        for (
            true_label,
            predicted_label,
        ) in zip(
            fold_true_labels,
            fold_predictions,
        )
    )


    fold_accuracy = (
        100
        * fold_correct
        / len(
            fold_true_labels
        )
    )


    fold_accuracies.append(
        fold_accuracy
    )


    all_true_labels.extend(
        fold_true_labels
    )


    all_predictions.extend(
        fold_predictions
    )


    print(
        f"\nBest Fold "
        f"{fold_index + 1} "
        f"Accuracy: "
        f"{fold_accuracy:.2f}%"
    )


# ============================================================
# FINAL CROSS-VALIDATION RESULTS
# ============================================================

print(
    "\n"
    + "=" * 70
)

print(
    "5-FOLD CROSS-VALIDATION RESULTS"
)

print(
    "=" * 70
)


for fold_index, accuracy in enumerate(
    fold_accuracies
):

    print(
        f"Fold "
        f"{fold_index + 1}: "
        f"{accuracy:.2f}%"
    )


mean_accuracy = statistics.mean(
    fold_accuracies
)


std_accuracy = statistics.stdev(
    fold_accuracies
)


print(
    f"\nMean Accuracy: "
    f"{mean_accuracy:.2f}%"
)

print(
    f"Standard Deviation: "
    f"{std_accuracy:.2f}%"
)


# ============================================================
# SAVE FOLD ACCURACIES CSV
# ============================================================

fold_csv_path = (
    RESULTS_DIR
    / "fold_accuracies.csv"
)


with open(
    fold_csv_path,
    "w",
    newline="",
    encoding="utf-8",
) as csv_file:

    writer = csv.writer(
        csv_file
    )


    writer.writerow([
        "Fold",
        "Accuracy (%)",
    ])


    for fold_index, accuracy in enumerate(
        fold_accuracies
    ):

        writer.writerow([
            fold_index + 1,
            round(
                accuracy,
                4,
            ),
        ])


    writer.writerow([])


    writer.writerow([
        "Mean Accuracy (%)",
        round(
            mean_accuracy,
            4,
        ),
    ])


    writer.writerow([
        "Standard Deviation (%)",
        round(
            std_accuracy,
            4,
        ),
    ])


# ============================================================
# OVERALL CONFUSION MATRIX
# ============================================================

matrix = confusion_matrix(
    all_true_labels,
    all_predictions,
)


print(
    "\nOverall Cross-Validation "
    "Confusion Matrix:"
)

print(
    matrix
)


# ============================================================
# SAVE CONFUSION MATRIX AS PNG
# ============================================================

figure, axis = plt.subplots(
    figsize=(6, 5)
)


matrix_image = axis.imshow(
    matrix
)


axis.set_title(
    "SariwaBa 5-Fold Cross-Validation "
    "Confusion Matrix"
)


axis.set_xlabel(
    "Predicted Label"
)


axis.set_ylabel(
    "Actual Label"
)


axis.set_xticks(
    range(
        len(
            base_dataset.classes
        )
    )
)


axis.set_yticks(
    range(
        len(
            base_dataset.classes
        )
    )
)


axis.set_xticklabels(
    base_dataset.classes
)


axis.set_yticklabels(
    base_dataset.classes
)


# Add numbers to each confusion matrix cell
for row in range(
    matrix.shape[0]
):

    for column in range(
        matrix.shape[1]
    ):

        axis.text(
            column,
            row,
            str(
                matrix[
                    row,
                    column
                ]
            ),
            ha="center",
            va="center",
        )


# Add scale bar
figure.colorbar(
    matrix_image,
    ax=axis,
)


figure.tight_layout()


confusion_matrix_path = (
    RESULTS_DIR
    / "cross_validation_confusion_matrix.png"
)


figure.savefig(
    confusion_matrix_path,
    dpi=300,
    bbox_inches="tight",
)


plt.close(
    figure
)


# ============================================================
# CLASSIFICATION REPORT
# ============================================================

report_dictionary = (
    classification_report(
        all_true_labels,
        all_predictions,
        target_names=(
            base_dataset.classes
        ),
        output_dict=True,
        zero_division=0,
    )
)


print(
    "\nOverall Classification Report:"
)


print(
    classification_report(
        all_true_labels,
        all_predictions,
        target_names=(
            base_dataset.classes
        ),
        digits=4,
        zero_division=0,
    )
)


# ============================================================
# SAVE METRICS CSV
# ============================================================

metrics_csv_path = (
    RESULTS_DIR
    / "cross_validation_metrics.csv"
)


with open(
    metrics_csv_path,
    "w",
    newline="",
    encoding="utf-8",
) as csv_file:

    writer = csv.writer(
        csv_file
    )


    writer.writerow([
        "Class",
        "Precision",
        "Recall",
        "F1-Score",
        "Support",
    ])


    # --------------------------------------------------------
    # CLASS METRICS
    # --------------------------------------------------------

    for class_name in (
        base_dataset.classes
    ):

        metrics = (
            report_dictionary[
                class_name
            ]
        )


        writer.writerow([
            class_name,

            round(
                metrics[
                    "precision"
                ],
                4,
            ),

            round(
                metrics[
                    "recall"
                ],
                4,
            ),

            round(
                metrics[
                    "f1-score"
                ],
                4,
            ),

            int(
                metrics[
                    "support"
                ]
            ),
        ])


    # --------------------------------------------------------
    # MACRO AVERAGE
    # --------------------------------------------------------

    macro_metrics = (
        report_dictionary[
            "macro avg"
        ]
    )


    writer.writerow([
        "Macro Average",

        round(
            macro_metrics[
                "precision"
            ],
            4,
        ),

        round(
            macro_metrics[
                "recall"
            ],
            4,
        ),

        round(
            macro_metrics[
                "f1-score"
            ],
            4,
        ),

        int(
            macro_metrics[
                "support"
            ]
        ),
    ])


    # --------------------------------------------------------
    # WEIGHTED AVERAGE
    # --------------------------------------------------------

    weighted_metrics = (
        report_dictionary[
            "weighted avg"
        ]
    )


    writer.writerow([
        "Weighted Average",

        round(
            weighted_metrics[
                "precision"
            ],
            4,
        ),

        round(
            weighted_metrics[
                "recall"
            ],
            4,
        ),

        round(
            weighted_metrics[
                "f1-score"
            ],
            4,
        ),

        int(
            weighted_metrics[
                "support"
            ]
        ),
    ])


    writer.writerow([])


    writer.writerow([
        "Overall Accuracy",
        round(
            report_dictionary[
                "accuracy"
            ],
            4,
        ),
    ])


    writer.writerow([
        "Mean Fold Accuracy (%)",
        round(
            mean_accuracy,
            4,
        ),
    ])


    writer.writerow([
        "Standard Deviation (%)",
        round(
            std_accuracy,
            4,
        ),
    ])


# ============================================================
# SAVE RAW CONFUSION MATRIX AS CSV
# ============================================================

confusion_csv_path = (
    RESULTS_DIR
    / "cross_validation_confusion_matrix.csv"
)


with open(
    confusion_csv_path,
    "w",
    newline="",
    encoding="utf-8",
) as csv_file:

    writer = csv.writer(
        csv_file
    )


    writer.writerow([
        "Actual / Predicted",
        *base_dataset.classes,
    ])


    for row_index, class_name in enumerate(
        base_dataset.classes
    ):

        writer.writerow([
            class_name,
            *matrix[
                row_index
            ].tolist(),
        ])


# ============================================================
# FINAL OUTPUT
# ============================================================

print(
    "\n"
    + "=" * 70
)

print(
    "RESULT FILES SAVED"
)

print(
    "=" * 70
)


print(
    "\nConfusion matrix image:"
)

print(
    confusion_matrix_path
)


print(
    "\nConfusion matrix CSV:"
)

print(
    confusion_csv_path
)


print(
    "\nClassification metrics CSV:"
)

print(
    metrics_csv_path
)


print(
    "\nFold accuracies CSV:"
)

print(
    fold_csv_path
)


print(
    "\nCross-validation complete."
)
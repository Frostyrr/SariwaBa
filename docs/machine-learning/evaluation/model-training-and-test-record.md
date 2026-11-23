# SariwaBa Model Training and Test Record

Updated 23 November 2026, Manila time.

## What changed today

| Model | Training on 23 November | Local backend model file |
| --- | --- | --- |
| A Photo checker | 6 epochs completed, epoch 3 selected | Earlier four-category model. The new candidate remains separate. |
| B Freshness classifier | 6 epochs completed, epoch 2 selected | Day 3 model applied. |
| C Eye finder | 15 epochs completed, with a restart from the last saved epoch after a GPU error | Day 3 YOLO model applied. |

The later tests on the three fish in `local_collection_v2` used those model versions. They did not train or replace any model. An epoch is one pass through the training photos.

## Equipment and methods

- **Photo collection.** The original local collection used Android and iPhone photos of eyes, gills, and whole tilapia. The new test batch contains three fish with Day 1 eye and whole-fish photos. Exact phone models and the new batch's capture device were not verified.
- **Eye annotations.** In Roboflow, boxes mark the fish and visible eye. We export YOLOv8 files and align the class numbers with the app before using them.
- **Training and testing.** A Windows development machine with an NVIDIA GeForce RTX 4050 Laptop GPU ran training using Python and PyTorch. Models A and B use MobileNetV3 Small. Model C uses YOLOv8 through Ultralytics. The local app runs its Django backend in Docker. The annotated new-batch YOLO test ran directly on Windows because Docker was off.
- **Data split.** Training photos teach the model. Validation photos help choose the saved version. Test photos measure the saved version. Keep all photos from the three new fish together across days. The original collection's YOLO training and test splits may contain different photos of the same fish.
- **Freshness labels.** The collector labeled the original Day 3 close-ups Not Fresh. The new Day 1 batch check recorded predictions. Its results should only be scored as freshness accuracy against confirmed labels.

## Training runs and test results

| Model | Training photos | Validation photos | Test photos | Key result |
| --- | ---: | ---: | ---: | --- |
| A | 2,301, including 618 Day 3 photos | 250 | 279 | Correct whole-fish routing rose from 18/48 to 34/48. Unsupported photos accepted as close-ups rose from 0/62 to 2/62. |
| B | 2,837, including 407 Day 3 close-ups | 441 | 390 | Accuracy rose from 274/390 (70.26%) to 377/390 (96.67%). The runs used different training mixes. |
| C | 311, including 156 original Day 3 images | 50 | 171 | Eye recall rose from 85.23% to 87.92%. Eye precision fell from 92.58% to 89.06%. |

The 407 original Day 3 close-ups also served as a check on examples the new Model B had trained on. It called all 407 Not Fresh. The previous version called 406 Fresh. This check describes those training examples.

### Did we use confusion matrices?

**Yes, for Models A and B.** A confusion matrix counts how often each expected category was predicted as each possible category. Rows are the expected labels and columns are the predictions. Model A saves a four-category matrix for eyes, gills, unsupported photos, and whole tilapia. It also separately counts what the app accepts, rejects, or routes to eye selection.

Model B's confusion matrices on the same 390 test photos are shown below.

| Expected label | Previous predicted Fresh | Previous predicted Not Fresh | Day 3 predicted Fresh | Day 3 predicted Not Fresh |
| --- | ---: | ---: | ---: | ---: |
| Fresh | 168 | 8 | 163 | 13 |
| Not Fresh | 108 | 106 | 0 | 214 |

For **Model C**, the reported evaluation compares predicted boxes with the annotated boxes. Precision describes how often predicted eye boxes matched. Recall describes how often annotated eyes were found. mAP50 summarizes detection across confidence settings at 50% box overlap. mAP50–95 averages the score over stricter overlap requirements as well.

## New batch Day 1 test

- **Model A.** Accepted 89 of 119 eye close-ups. Of 75 original whole-fish photos, it recognized 19 as whole tilapia and marked 56 uncertain. It accepted the first YOLO eye crop from all 75.
- **Model B.** Predicted Fresh for 91 of 119 eye close-ups and 57 of 75 first YOLO crops. The remaining predictions were Not Fresh. Confirm the expected freshness labels before interpreting these as errors.
- **Model C.** Proposed a crop on all 75 original photos. A separate test of the annotated export used all 75 images, including the one Roboflow placed in its train folder. There were 74 annotated eyes. Eye precision was **97.31%**, recall **97.69%**, mAP50 **97.41%**, and mAP50–95 **47.42%**. The lower strict-overlap score shows room to improve box placement.

All 51 backend classification tests passed before the eye finder switch. The new detector returned eye proposals on all 10 activation smoke-test photos and the local server passed its health check. Those checks cover app behavior. The annotated test measures eye detection.

## Project records

- [Day 3 training details](../methods/tilapia-validation-pipeline.md#day-3-training-and-test-results-on-23-november-2026)
- [Historical session log](../training/historical-session-log.md)
- The local run folder at `backend/datasets/local_collection/training_runs/` contains the Day 3 Model A evaluation, Model B comparison, both new-batch test records, and the late-23 November balanced retrain artifacts under `balanced_2026-11-23/`.
- The local YOLO run at `backend/datasets/local_collection/yolo/batch_2026-11-21/day03_detector_2026-11-23/` contains the epoch results, previous model backup, and comparison.

## Late 23 November 2026 — Balanced Local Retrain (Models A & B)

After testing the freshly bought Batch 2 (`local_collection_v2/day_01`, photographed on a bright red tray), analysis showed two causes of errors:
1. The earlier 23 November Model B manifest (`day03_2026-11-23/freshness.csv`) contained a **13.6:1 local Non-Fresh imbalance** (`407` local Day 3 Non-Fresh photos vs. only `30` local Day 1–2 Fresh photos, and `0` YOLO eye crops), biasing Model B to predict Not Fresh on local phone eyes.
2. Model A had not yet seen Batch 1 Day 3 dark eyes or Tilapia photographed on a bright red plastic tray (overlapping with `red_objects_on_the_same_tray` / `red_cloth` hard negatives), causing `56/75` (74.7%) of Batch 2 whole-fish photos and `30/119` (25.2%) of eyes to be marked `CONTENT_UNCERTAIN`.

| Model | Version / Artifact | Data split | Measure & result | Active in local app? |
| --- | --- | --- | --- | --- |
| A Photo checker | `validator-f10d30ceded6` (`sariwaba_validator.pth`, thr `0.85`, 10 ep, best ep 5) | 2,093 train (added Batch 1 Day 3 + Batch 2 red-tray Tilapia) / 250 val / 279 test | Held-out test: **0.0%** unsupported FA (`0/62`), **0.0%** unsup-whole (`0/62`), **0.0%** whole-fish false route (`0/48`), **0/70** red hard-negative FA. Batch 1 Day 3 eyes: **100%** (`41/41` Android, `60/60` iPhone). Batch 2 red-tray whole: **100%** (`75/75`, up from `25.3%`), eyes: **99.2%** (`118/119`, up from `74.8%`), YOLO eye crops: **100%** (`149/149`). | **Yes** (`sariwaba_validator.pth`, Docker restarted) |
| B Freshness classifier | `model_b_balanced.pth` → `sariwaba_mobilenetv3_best.pth` (10 ep, best ep 2, unfrozen from block 4) | 3,351 train (1:1 balanced Batch 1 local: `254` Fresh vs `231` NonFresh eyes incl. `80/80` YOLO crops; `233` vs `233` gills) / 441 val / 390 test (`local_collection_v2/day_01` kept **100% held out**) | Val accuracy **99.55%**, held-out test accuracy **98.72%** (up from `96.67%`; `DS1` Fresh eyes `78.0% → 98.0%`). Batch 1 Day 1–2 iPhone eyes: **100%** (`120/120`, up from `51.7–55.0%`). Unseen Batch 2 (`local_collection_v2/day_01`) YOLO eye crops: **88.0%** Fresh (`66/75`, up from `76.0%`); uncropped wide red-tray eyes: `70.6%` (`84/119`, with cropping flipping `17/19` tested misses to Fresh). | **Yes** (`sariwaba_mobilenetv3_best.pth`, Docker restarted) |
| C Eye finder | Day 3 `sariwaba_eye_detector.pt` (unchanged) | Evaluated on `local_collection_v2/day_01` (`75` whole) | Already **97.41% mAP50** (`75/75` proposals); no retraining needed. | **Yes** (unchanged) |

- **Verification:** All 29 targeted backend classification/validator/eye-proposal tests passed (`1.05s`), and live Docker API checks on `http://localhost:8000` confirmed `POST /api/v1/classify/eye-proposals/` and `POST /api/v1/classify/` returned HTTP 200 with `validator-f10d30ceded6` (`region_verified: True`).
- **Artifacts:** `backend/datasets/local_collection/training_runs/balanced_2026-11-23/` (`model_b_manifest.csv`, `model_b_balanced.pth`, `model_a_metadata/`, `model_a_balanced/`).

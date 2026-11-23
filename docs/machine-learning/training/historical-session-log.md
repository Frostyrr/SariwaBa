# Historical Training Session Log

Chronological log of notable ML diagnosis, retraining, and activation sessions.

---

## Session — 23 November 2026 (Late Evening, Manila Time): Batch 2 (`local_collection_v2/day_01`) Diagnosis & Balanced Retrain

### Trigger
Freshly bought market tilapia photos under `backend/datasets/local_collection_v2/day_01/` (`119` eyes, `75` whole fish on a bright red plastic tray) were frequently rejected by Model A (`CONTENT_UNCERTAIN`) or misclassified as Not Fresh by Model B.

### Root Causes Identified
1. **Model B local-domain class imbalance (`13.6:1`):** The earlier 23 November run (`day03_2026-11-23/freshness.csv`) included `407` local Day 3 Non-Fresh photos (`174` eyes, `233` gills) against only `30` local Day 1–2 Fresh photos (`14` eyes, `16` gills) and `0` YOLO eye crops, causing strong Not-Fresh bias on local phone eye photos (including `45–48%` errors on Batch 1 Day 1–2 iPhone eyes).
2. **Model A red-tray & Day 3 gap:** Batch 2 sits on a bright red plastic tray that overlapped with `unsupported/hard_negatives/red_objects_on_the_same_tray` and `red_cloth` (`56/75` whole photos and `30/119` eyes marked `CONTENT_UNCERTAIN`). Model A had also not trained on Batch 1 Day 3 dark eyes (`58.5%` Android / `71.7%` iPhone acceptance).
3. **Model C (YOLO) healthy:** Already achieved `97.41%` eye `mAP50` and `75/75` eye proposals on `local_collection_v2/day_01`; kept unchanged.

### Retraining & Artifacts (`backend/datasets/local_collection/training_runs/balanced_2026-11-23/`)
- **Hardware note:** This run executed on CPU (`backend/.venv`) to avoid laptop battery power spikes; future training runs should use the NVIDIA GeForce RTX 4050 GPU (`.venv-yolo-gpu`, CUDA).
- **Model B (`model_b_balanced.pth` → promoted to `backend/ml/models/sariwaba_mobilenetv3_best.pth`):**
  - Manifest: `model_b_manifest.csv` (`4,182` total deduplicated rows: `3,351` train / `441` val / `390` test).
  - Local Batch 1 balanced ~1:1: `254` Fresh vs `231` NonFresh eyes (including `80/80` matched YOLO eye crops) and `233` Fresh vs `233` NonFresh gills.
  - **`local_collection_v2/day_01` kept 100% held out** from Model B training to avoid red-tray shortcuts.
  - Config: MobileNetV3-Small, `--unfreeze-from 4`, 10 epochs, `batch_size=32`, `backbone_lr=2e-4`, `head_lr=1e-3`, `label_smoothing=0.05`. Best checkpoint: **Epoch 2** (`val_macro_f1 = 0.9955`, `val_acc = 99.55%`, held-out `test_acc = 98.72%`).
- **Model A (`model_a_balanced/sariwaba_validator.pth` → promoted to `backend/ml/models/sariwaba_validator.pth`):**
  - Manifest: `model_a_metadata/` (`2,093` train / `250` val / `279` test; added Batch 1 Day 3 + Batch 2 Day 1 red-tray Tilapia to `train` only; `val`, `test`, and `challenge_images` kept strictly disjoint).
  - Config: 4-class MobileNetV3-Small, `--unfreeze-from 4`, 10 epochs, `--min-threshold 0.85`, `label_smoothing=0.02`. Best checkpoint: **Epoch 5** (`val_macro_f1 = 0.9803`, `version = validator-f10d30ceded6`, calibrated `acceptance_threshold = 0.85`).

### Key Before → After Results
- **Model B:**
  - Held-out test (`390`): `96.67% → 98.72%` (`DS1` Fresh eyes `78.0% → 98.0%`).
  - Batch 1 Day 1 / Day 2 iPhone eyes (`60` each): `55.0% / 51.7% → 100.0% / 100.0%`.
  - Unseen Batch 2 (`local_collection_v2/day_01`) YOLO eye crops (`75`): `76.0% → 88.0%` (`66/75`, errors halved).
  - Unseen Batch 2 uncropped red-tray eyes (`119`): `70.6%` (`84/119`; cropping out the red tray with YOLO flipped `17/19` tested misses back to Fresh).
- **Model A:**
  - Held-out test (`279`): `0.0%` unsupported FA (`0/62`), `0.0%` unsup-whole (`0/62`), `0.0%` whole-fish false route (`0/48`, improved from `4.2%`).
  - Red hard negatives (`60` `red_cloth` + `10` `red_objects_on_the_same_tray`): `100%` blocked (`0/70` FA).
  - Batch 1 Day 3 Android / iPhone eyes: `58.5% / 71.7% → 100.0% / 100.0%`.
  - Batch 2 red-tray whole (`75`): `25.3% → 100.0%`; eyes (`119`): `74.8% → 99.2%`; all YOLO crops (`149`): `100.0%`.

### Activation & Verification
- Restarted Docker container `sariwaba_backend` (`docker compose restart backend`).
- All 29 targeted backend tests passed (`1.05s`).
- Live HTTP checks against `http://localhost:8000` confirmed `POST /api/v1/classify/eye-proposals/` and `POST /api/v1/classify/` returned HTTP 200 with `validator-f10d30ceded6` (`region_verified: True`).

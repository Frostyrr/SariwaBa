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


---

## Session — 25 November 2026 (Evening, Manila Time): Final-Day Dataset Audit (`local_collection` Day 5 & `local_collection_v2` Day 3) and Hold-Out Decision

### Context & Dataset Intake
Collection concluded on the morning of 25 November 2026 (`24 November` skipped due to full-day academic schedule):
- **`local_collection` Day 5 (`226` photos — severely decomposed / Not Fresh):** `android/day 5` (`19` eyes, `35` gills) and `iphone_jpg/day_05` (`68` eyes, `68` gills, `36` whole).
- **`local_collection_v2` Day 3 (`240` photos — spoiled / Not Fresh):** `day_03/eyes` (`128`) and `day_03/whole` (`112`); gills omitted due to small specimen size.

### Verified Historical Split Lineage (Active Checkpoints)
- **`local_collection` Days 1–2 (Fresh):** Used in `train` across Models A, B, and C (plus `50` images in YOLO `val` and `41` eye crops in Model A `val`/`test`).
- **`local_collection` Day 3 (Not Fresh):** Used `100%` in `train` for active Models A and B (`balanced_2026-11-23`), and split `156` `train` / `171` `test` in active Model C (`day03_detector_2026-11-23`).
- **`local_collection_v2` Day 1 (Fresh):** Kept **`100%` held-out (`test` only)** for Model B and Model C; `120` photos (`60` eyes, `60` whole) were included in Model A `train` for red-tray calibration (`day_03` remained unseen by all three models).

### Evaluation Findings & Strategic Decision (Do Not Retrain — Keep as Held-Out Test & Stress-Test Sets)
1. **Strong End-to-End Generalization on Unseen Batch 2 (`local_collection_v2`):**
   - On `day_03/whole` (`112` spoiled photos), Model C proposed an eye on **`111/112` (`99.11%`)**, Model A accepted **`104/111` (`93.69%`)**, and Model B predicted **Not Fresh on `100/104` (`96.15%`)**.
   - Combined with `day_01/whole` (`66/75` = `88.00%` Fresh), active Models C → A → B achieved **92.74% end-to-end accuracy (`166/179`)** on a local fish cohort completely unseen by Models B and C.
   - Visual inspection showed `day_03/eyes` (`128` photos) were framed as wide half-body shots on the red lid rather than tight eye close-ups (`17.97%` direct Model A acceptance; `61.72%` raw Model B accuracy), whereas routing them through YOLO cropping lifted Model B accuracy to **`87.23%`** (`41/47`).
2. **Batch 1 Day 5 Extreme-Decomposition Boundary Identified:**
   - Day 5 eyes still present in whole-fish or close-up shots were classified **Not Fresh** at **`91.2%–100.0%`** by Model B, while liquefied/missing eyeballs in `20/36` Day 5 whole carcasses appropriately yielded no YOLO eye box (`44.44%` proposal rate).
   - Day 5 gill photos contained a metal knife blade prying open dark, decomposed cavities (`57%–71%` rejected as `CONTENT_UNCERTAIN` by Model A; wide silvery-scale framing misclassified by Model B). Training on knife-occluded putrid cavities or empty skull sockets would degrade retail-stage precision.
3. **Decision:** Keep all active checkpoints unchanged (`validator-f10d30ceded6`, `sariwaba_mobilenetv3_best.pth`, `sariwaba_eye_detector.pt`). Preserve `local_collection_v2` (Day 1 + Day 3) as the primary **independent local test cohort** (including optional Roboflow annotation of `v2/day_03/whole` for YOLO box-IoU testing only), and retain `local_collection` Day 5 as a **documented extreme-spoilage boundary/stress test**.
4. **Saved Artifacts:**
   - Standard & Batch 2 confusion matrices (`.png`, `.csv`, `.json`): `backend/ml/results/active_2026-11-25/`
   - Detailed Nov 25 cohort JSON metrics: `backend/datasets/local_collection/training_runs/nov25_final_day_eval/nov25_evaluation_results.json`

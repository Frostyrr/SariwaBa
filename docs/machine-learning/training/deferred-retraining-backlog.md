# Deferred ML Retraining Backlog & Implementation Tracker

- **Created / Recorded Date:** 26 November 2026 (Manila time, `UTC+8`)
- **Last Updated:** 26 November 2026
- **Locked Active Baseline Checkpoints (Untouched on 2026-11-26):**
  - **Model A (Photo Checker / Supported-Input Gate):** `backend/ml/models/sariwaba_validator.pth` (`validator-f10d30ceded6`, `acceptance_threshold = 0.85`)
  - **Model B (Freshness Classifier):** `backend/ml/models/sariwaba_mobilenetv3_best.pth` (`model_b_balanced.pth`, 2-class `Fresh` / `NonFresh`)
  - **Model C (YOLO Eye Finder):** `backend/ml/models/sariwaba_eye_detector.pt` (Day 3 `YOLOv8n`, `{0: 'fish', 1: 'eye'}`)

---

## Purpose & Maintenance Rule

Following the comprehensive ML pipeline audit on **26 November 2026**, all **zero-retraining** frontend and backend fixes (Audit Items `#1, #2, #5, #6, #8, #9, #10 runtime guard, #11, #12`, plus the frontend `1:1` square-crop mitigation for `#3`) were **implemented immediately on 2026-11-26** without altering the locked model weights.

The items below **require retraining** (because changing runtime preprocessing or label/head structure alone without retraining would introduce a train/serve distribution mismatch against the locked checkpoints).

> [!IMPORTANT]
> **Mandatory Update Rule When Implementing Any Item Below:**
> Whenever one of these items (`RT-01` through `RT-04`) is eventually implemented and retrained, you **MUST** update this file in the same commit/session:
> 1. Change the item's **Status** from `[ ] Deferred — Requires Retraining` to `[x] Implemented / Done (YYYY-MM-DD)`.
> 2. Add a dated entry to the **[Implementation & Completion Log](#implementation--completion-log)** table at the bottom of this document recording the exact date, code files changed, new checkpoint version/hash, held-out test results, and whether the checkpoint is active in Docker/local runtime.
> 3. Append the corresponding training and evaluation metrics to [model-training-and-test-record.md](../evaluation/model-training-and-test-record.md).

---

## Deferred Retraining Items

### `RT-01` — Aspect-Preserving Resize / Square Letterboxing in `_build_eval_transform` (Audit #3 Backend Side)
- **Status:** `[ ] Deferred — Requires Retraining` *(Partial zero-retraining frontend mitigation `[x] Implemented on 2026-11-26` for manual & YOLO crops)*
- **Locations:**
  - `backend/ml/predict.py` (`_build_eval_transform`)
  - `backend/ml/validator.py` (imports `_build_eval_transform`)
  - `backend/ml/shared_dataset.py` & `backend/ml/train_grouped.py` (training/eval transforms)
- **Why Deferred Until Retraining:**
  - Models A and B were trained and threshold-calibrated using `transforms.Resize((224, 224))`, which warps non-square `4:3` or `16:9` full-frame close-ups into a `1:1` square (`25%–44%` anisotropic compression along the long axis).
  - Switching `_build_eval_transform` at runtime to `Resize(256) + CenterCrop(224)` or square padding *without* retraining would clip peripheral gill/head context or introduce border bars that the current weights never saw during training.
  - Note: YOLO eye proposals (`padded_crop`) and manual crops from `RoiCropperWidget` (updated **2026-11-26**) already send `1:1` square crops, where `Resize((224, 224))` causes **zero** aspect-ratio distortion. Only uncropped "Full Close-Up" `4:3`/`16:9` uploads remain affected.
- **What to Do When Retraining:**
  1. Update both training (`shared_dataset.py`, `train_grouped.py`) and inference (`predict.py`) transforms simultaneously to use aspect-preserving preprocessing (e.g., `Resize(256) + CenterCrop(224)` or natural-context square cropping prior to `Resize((224, 224))`).
  2. Retrain and re-calibrate Model A (`acceptance_threshold` on validation split) and Model B, verify held-out test metrics, and mark `RT-01` as **Done** below.

---

### `RT-02` — Remove `Image.draft("RGB", (512, 512))` from Training Data Loaders (Audit #4)
- **Status:** `[ ] Deferred — Requires Retraining`
- **Locations:**
  - `backend/ml/shared_dataset.py` (`load_rgb_image`, line ~301)
  - `backend/ml/train_grouped.py` (dataset loader, line ~417)
- **Why Deferred Until Retraining:**
  - Training loaders call `img.draft("RGB", (512, 512))` on JPEGs *before* `ImageOps.exif_transpose()`, triggering libjpeg `1/2`, `1/4`, or `1/8` DCT block subsampling on `3000–4032 px` phone JPEGs, whereas runtime inference (`predict.py`, `validator.py`) decodes full-resolution JPEGs cleanly with `exif_transpose()` first.
  - Adding `draft()` to runtime inference would risk EXIF orientation quirks and degraded crop sharpness, while current checkpoints already achieve `98.72%` held-out test and `92.74%` unseen Batch 2 accuracy without `draft()` at inference.
- **What to Do When Retraining:**
  1. Remove `Image.draft("RGB", (512, 512))` in `shared_dataset.py` and `train_grouped.py` (or pre-cache EXIF-normalized `512 px` PNG/JPEG training tiles offline once) before starting the next Model A / Model B training run.
  2. Verify train/serve tensor parity (`max |tensor_train_eval - tensor_runtime| == 0`) on a sample `4032x3024` EXIF-rotated phone JPEG, then mark `RT-02` as **Done** below.

---

### `RT-03` — Display P3 / Wide-Gamut ICC Profile Conversion to sRGB (Audit #7)
- **Status:** `[ ] Deferred — Requires Retraining`
- **Locations:**
  - `backend/ml/predict.py` (`predict_image`)
  - `backend/ml/validator.py` (`validate_image`)
  - `backend/ml/shared_dataset.py` & `backend/ml/train_grouped.py`
- **Why Deferred Until Retraining:**
  - iPhone camera captures (`HEIC` and `iphone_jpg`) often carry a **Display P3** ICC color profile (~25% wider red-orange gamut than sRGB). Pillow's `.convert("RGB")` strips ICC metadata without converting pixel primaries to sRGB.
  - Because `iphone_jpg` images in the training set were loaded with `.convert("RGB")` (without `PIL.ImageCms.profileToProfile`), converting *only* runtime uploads to sRGB without retraining could shift red gill saturation relative to what Models A and B learned during training.
- **What to Do When Retraining:**
  1. Add a shared helper `to_srgb_rgb(img: Image.Image) -> Image.Image` using `PIL.ImageCms` (converting embedded ICC profiles to `ImageCms.createProfile("sRGB")` before `.convert("RGB")`, with safe fallback when no ICC profile is present).
  2. Apply `to_srgb_rgb()` identically in **both** training loaders (`shared_dataset.py`, `train_grouped.py`) and runtime inference (`predict.py`, `validator.py`, `views.py`), retrain Models A and B, and mark `RT-03` as **Done** below.

---

### `RT-04` — Optional Structural Scope Expansions: Multi-Species Gate & Region-Conditioned Freshness Heads (Audit #10 Model Side)
- **Status:** `[ ] Deferred — Optional Future Scope (Requires New Data + Retraining)`
- **Locations:**
  - `backend/ml/train_validator.py` & `backend/ml/validator.py` (`species_verified` is currently `False` by design)
  - `backend/ml/train_grouped.py` & `backend/ml/predict.py` (shared 2-class `Fresh`/`NonFresh` head across Eye and Gill)
- **Why Deferred:**
  - By project scope, SariwaBa assesses **Tilapia** (`species_verified: False` is truthfully returned by the API and surfaced in the UI). Training Model A to reject close-up eyes/gills of other Philippine market species (*Bangus*, *Galunggong*, *Maya-Maya*) would require collecting and labeling a dedicated multi-species negative dataset.
  - Similarly, Model B uses a single MobileNetV3-Small head for both `eye` and `gill` (`98.72%` held-out test accuracy) and ignores `region_type` inside `predict_image()`. Conditioning on `region_type` or training separate Eye vs. Gill heads would require retraining and maintaining two checkpoints or a multi-head architecture.
- **What to Do If Scope Expands in Future:**
  1. Collect balanced multi-species close-up negatives (for Model A) and/or train separate/region-conditioned Eye and Gill heads (for Model B).
  2. Update `species_verified` or `predict_image(..., region_type=...)` only after held-out evaluation passes target false-accept rates, and mark `RT-04` as **Done** below.

---

## Implementation & Completion Log

Record every completed item here in chronological order so panel reviewers and maintainers can see exactly what was implemented and when.

| Date (`YYYY-MM-DD`) | Item ID / Scope | Status | Summary of Changes & Checkpoints | Verified By / Test Record |
| :--- | :--- | :--- | :--- | :--- |
| `2026-11-26` | **Zero-Retraining Audit Fixes** (`#1, #2, #5, #6, #8, #9, #10 guard/UI, #11, #12` + `#3` frontend `1:1` crop mitigation) | **Implemented / Done** | Enforced Model A gate on all YOLO `eye_proposals` crops; cleared stale `selectedEyeProposalIndex` on manual/full crops; added strict ISO-BMFF `ftyp` HEIC brand validation & server `image_width`/`image_height` metadata; aligned `processBatch` with `selectedRegion` & YOLO fallback codes; locked `RoiCropperWidget` output crops to `1:1` natural-pixel squares; added web drag-and-drop `<=2048 px` canvas normalization; added `0.55` `FRESHNESS_UNCERTAIN` coin-flip floor & UI scope notice; enabled YOLO `classes=[0,1]` fish-body containment ranking + `DEVICE` + bundle locks + single-pass decode + `10 MB` RAM upload limit. Locked checkpoints (`validator-f10d30ceded6`, `model_b_balanced.pth`, `sariwaba_eye_detector.pt`) kept unchanged. | Django test suite + Flutter analyzer & widget/unit tests passed (`2026-11-26`). |
| *Pending* | `RT-01` (Backend `_build_eval_transform` aspect-preserving resize) | Deferred (Requires Retraining) | *Update with date, new Model A & B checkpoint hashes, and test accuracy when implemented.* | *Link to `model-training-and-test-record.md` section.* |
| *Pending* | `RT-02` (Remove `Image.draft()` in training loaders) | Deferred (Requires Retraining) | *Update with date, training run folder, and tensor-parity check when implemented.* | *Link to `model-training-and-test-record.md` section.* |
| *Pending* | `RT-03` (`ImageCms` Display P3 $\rightarrow$ sRGB conversion) | Deferred (Requires Retraining) | *Update with date, ICC conversion helper path, and retrained checkpoint results when implemented.* | *Link to `model-training-and-test-record.md` section.* |
| *Pending* | `RT-04` (Multi-species gate / separate Eye & Gill heads) | Deferred (Optional Scope Expansion) | *Update with date, dataset counts, and checkpoint hashes if scope expands.* | *Link to `model-training-and-test-record.md` section.* |

# SariwaBa Defense Questions and Answers

Updated 25 November 2026. This guide describes the locked active configuration: four-category Model A (`validator-f10d30ceded6`, threshold `0.85`), balanced Model B (`sariwaba_mobilenetv3_best.pth`, Epoch 2), and Day 3 Model C (`sariwaba_eye_detector.pt`, YOLOv8n).

## How confidence is calculated

| Model | Where its score comes from | What the app does with it |
| --- | --- | --- |
| **A Photo checker** (`MobileNetV3-Small`) | Outputs four raw scores (logits) for `eye`, `gill`, `unsupported`, and `whole_tilapia`. Softmax converts them into scores between `0` and `1` summing to `1.0`. The largest score is the selected category's confidence. | Requires a minimum calibrated confidence of **`0.85`** (otherwise returns `CONTENT_UNCERTAIN`). Confident `whole_tilapia` uploads trigger `WHOLE_TILAPIA_CLOSE_UP_REQUIRED` (or automatic YOLO eye-crop proposals), and region mismatches (`eye` vs. `gill`) return `REGION_MISMATCH`. |
| **B Freshness classifier** (`MobileNetV3-Small`) | Outputs two raw scores (logits). Softmax converts them into `Fresh` and `Not Fresh` scores summing to `1.0`. The larger score becomes the prediction confidence. | Runs **only after** Model A accepts the image. Returns the winning label (`Fresh` or `Not Fresh`) and its Softmax score without a separate minimum cutoff. |
| **C YOLO eye finder** (`YOLOv8n`) | Scores each predicted bounding box (`fish` or `eye`) independently; box scores do not sum across the image. | Filters `eye` boxes at a minimum confidence of **`0.25`**, expands each eye box by **`2.5x`** (`padded_crop`), and validates proposed crops with Model A before offering them to the user. |

**What does 93% Fresh mean?** Model B's Softmax layer gave `Fresh` a score of `0.93` (`93%`) and `Not Fresh` `0.07` (`7%`) for that single image. It reflects how strongly the classifier favored `Fresh`, not a calibrated laboratory guarantee that `93%` of such fish are safe or fresh. System accuracy is measured separately across labeled test sets.

**Do you average the three confidence scores?** No. Each model answers a different question: Model C locates the eye, Model A verifies the photo type/region, and Model B classifies freshness from the verified close-up.

**Why are the cutoffs different (`0.85` vs. `0.25`)?** Model A's `0.85` threshold was calibrated on validation images to achieve a `0.0%` false-accept rate on unsupported objects. YOLO's `0.25` cutoff filters candidate eye boxes before Model A double-checks the resulting crop. Neither cutoff is an accuracy score.

## Questions the panel may ask

**Why use eyes and gills?** Postharvest spoilage cues—corneal cloudiness, sunken eyes, and gill discoloration from bright red to brownish/pale—are concentrated in those regions. Whole-fish uploads use Model C (YOLO) to automatically crop the eye for the same freshness classifier, which is also practical when small tilapia have opercula too tight to open non-destructively.

**Why separate the models?** Separating input validation (Model A), eye localization (Model C), and freshness classification (Model B) lets the app give specific user feedback (`UNSUPPORTED_IMAGE`, `REGION_MISMATCH`, `WHOLE_TILAPIA_CLOSE_UP_REQUIRED`) and lets us audit, calibrate, or retrain each stage independently.

**How did you train the models? Are they overfit or underfit?**
- **Transfer learning (partial fine-tuning):** Models A and B started from ImageNet-pretrained `MobileNetV3-Small`, keeping early edge/color blocks (`0–3`) frozen and fine-tuning blocks `4–12` (`lr = 2e-4`) plus the classification head (`lr = 1e-3`) with augmentations, label smoothing, and validation best-epoch selection. Model C fine-tuned `YOLOv8n` on Roboflow `fish` and `eye` boxes.
- **Fit status:**
  - **Model B** shows a **good (normal) fit**: `99.85%` train, `99.55%` validation, and **`98.72%`** held-out test (`390` photos), plus **`92.74%`** end-to-end on unseen local Batch 2 (`179` whole-fish YOLO scans), with mild background sensitivity only when wide uncropped shots include bright colored trays.
  - **Model A** shows a **good operational fit**: `99.57%` train, `98.40%` validation, `92.83%` raw test argmax, and **`0.0%` unsupported false accepts (`0/62`)** / **`0.0%` whole-fish false routes (`0/48`)** once the `0.85` threshold gate is applied.
  - **Model C** generalizes strongly on unseen Batch 2 whole fish (**`95.39%` eye `mAP50`**, **`97.32%` overall `mAP50`** across `187` Day 1 + Day 3 photos), with moderate strict-overlap `mAP50–95` (`49.36%`, improved from `47.42%` on Day 1 to `51.38%` on Day 3 with tighter eye-ring boxes).

**How did you split the data and track spoilage?**
- **Batch 1 (`local_collection`):** Bought fresh from the market on Day 1, photographed immediately, and refrigerated until Day 2 (remaining Fresh). After Day 2 photography, fish were placed in an ice bucket in an ambient storage room, becoming visibly Not Fresh by Day 3 and reaching advanced putrefaction by Day 5 (Day 4 skipped due to full-day classes). Days 1–3 were used in `train` for Models A and B (balanced ~1:1 in `balanced_2026-11-23`), while Day 5 (`226` photos) was kept strictly as an out-of-distribution extreme-spoilage stress test.
- **Batch 2 (`local_collection_v2`):** Three market tilapia photographed on Day 1 (`Fresh`, `75` whole, `119` eyes) and Day 3 (`Not Fresh`, `112` whole, `128` eyes; Day 2 skipped). Kept **100% held out from Model B and Model C training/validation** as an independent local test cohort (`120` Day 1 images were used in Model A tray calibration; Day 3 was unseen by all three models).

**Did you use confusion matrices?** Yes—up-to-date confusion matrices for **all three active models** are saved in `backend/ml/results/active_2026-11-25/`:
- **Model A (`279` held-out test photos):** `97/103` `eye`, `66/66` `gill`, `61/62` `unsupported`, `35/48` `whole_tilapia` raw argmax, with **`0/62` (`0.0%`)** unsupported false accepts after the `0.85` gate.
- **Model B (`390` held-out test photos):** **`174/176` (`98.9%`)** `Fresh` and **`211/214` (`98.6%`)** `Not Fresh` (**`98.72%`** overall).
- **End-to-End Unseen Batch 2 (`179` gated whole-fish $\rightarrow$ YOLO eye crops):** **`66/75` (`88.0%`)** Day 1 `Fresh` and **`100/104` (`96.2%`)** Day 3 `Not Fresh` (**`92.74%`** overall).
- **Model C (`187` unseen Batch 2 whole-fish photos at runtime `conf = 0.25`):** Matched **`178/186` (`95.7%`)** annotated eyes (`95.39%` eye `mAP50`).

**How many epochs did the active models train?** Active Model A trained for `10` epochs and selected **Epoch 5** (`val_macro_f1 = 0.9803`). Active Model B trained for `10` epochs and selected **Epoch 2** (`val_macro_f1 = 0.9955`). Active Model C trained for `15` epochs (resuming from Epoch 9 with batch size `8` after a GPU memory interruption).

**Can the app certify that a fish is safe to eat?** No. SariwaBa provides a non-destructive **preliminary visual freshness screening** based on external eye and gill appearance; it cannot detect internal bacterial load, parasites, or chemical spoilage, as stated in the app's disclaimer.

## Evidence and implementation

- [Latest confusion matrices & JSON metrics (`active_2026-11-25`)](../../../backend/ml/results/active_2026-11-25/)
- [Training runs, equipment, storage protocol, and test counts](../evaluation/model-training-and-test-record.md)
- [Historical training & evaluation session log](../training/historical-session-log.md)
- [Model A scoring and input rules](../../../backend/ml/validator.py)
- [Model B confidence calculation](../../../backend/ml/predict.py)
- [YOLO crop proposal code](../../../backend/ml/eye_proposals.py)
- [API response and scan flow](../../../backend/classification/views.py)

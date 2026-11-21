# Whole-fish eye detection

Model A's localization candidate uses boxes for fish and visible eyes. Each
annotation nests the eyes under the fish they belong to. The model learns the
two box classes. Matching predicted eyes to the right fish in a crowded image
will need its own evaluation when we connect the detector to the scanner.

Create a JSON array with one entry per photo. Coordinates are pixel corners
`[left, top, right, bottom]` on the photo after EXIF orientation is applied.
Photo paths are relative to the manifest directory.

```json
[
  {
    "image": "photos/market-01.jpg",
    "session_id": "market-visit-01",
    "split": "train",
    "fish": [
      {
        "specimen_id": "fish-001",
        "box": [180, 120, 920, 1600],
        "eyes": [[470, 250, 568, 355]]
      }
    ]
  }
]
```

Use an empty `eyes` array for a fish with no visible eye and an empty `fish`
array for a photo without fish. Label all visible targets. Use the same specimen
ID across all photos of a fish. Keep all photos from a session in one split.
Reserve market sessions for validation and the final test, with annotated eyes in
each split. The tray photo discussed in this chat is reserved for evaluation.

From the backend directory:

```powershell
.venv/Scripts/python.exe -m ml.train_eye_detector path/to/photos.json --audit-only
.venv/Scripts/python.exe -m ml.train_eye_detector path/to/photos.json --output ml/candidates/eye-detector-v1.pth
```

Training uses pretrained MobileNetV3 backbone weights and may download them on
the first run. The trainer selects an epoch on validation eye F1 and reports
held-out fish and eye localization counts at IoU 0.5. The configured score
threshold is a starting point. Review missed eyes and detections on unrelated
objects before integrating a candidate. This detector does not predict species
or freshness. Species verification requires confirmed species labels and its own
evaluation. The existing scanner continues to use its eye or gill crop flow.

## YOLO pilot

The first market visit export contains clean JPEGs under `images` and matching
YOLO files under `labels`. From the backend directory, audit the export with:

```powershell
.venv/Scripts/python.exe -m ml.yolo_eye_pilot datasets/SariwaBa-eye-dataset/yolo_pilot/market-visit-01
```

Run training in a Python environment with Ultralytics installed. Pass a
pretrained detection checkpoint with `--weights` and a new directory with
`--output`. For a one-epoch pipeline check on the existing batch, add
`--smoke --epochs 1`. This reuses the training images for the tool's validation
step and marks the run as smoke-only. For model selection, pass
`--val-session <separate-session-directory>` instead of `--smoke` and reserve
another session for final evaluation.

### Scanner integration

Install Ultralytics in the Django runtime and set `EYE_DETECTOR_CHECKPOINT`
to the absolute path to a trusted, evaluated fish/eye checkpoint
(`0 = fish`, `1 = eye`). Restart Django after changing the checkpoint.
Build or run Flutter with `--dart-define=ENABLE_EYE_PROPOSALS=true` to
request eye proposals automatically on new uploads in Eye mode. The Django
detector runs on CPU. Gill mode uses the manual crop editor.

The scanner sends the original photo to `POST /api/v1/classify/eye-proposals/`.
Model A checks it first. An Eye close-up goes straight to the scanner preview,
and rejected images show the validator's rejection. The whole-tilapia class
routes to YOLO and requires a validator checkpoint that supports that class.
One proposal appears directly in the scanner preview. With multiple proposals,
the user selects an eye on the original photo. If the request fails or returns
no eye, the manual editor opens. Classification starts when the user presses
**Validate & Classify Freshness** and runs the existing validation and
freshness pipeline on the selected crop.

### Accuracy plan

1. **YOLO eye localization.** Review the current training boxes and add
   training photos from additional fish and sessions, including small eyes,
   glare, and crowded trays. Include fish-free photos and fish with obscured
   eyes. Use a different capture group for validation and reserve another
   group for final testing. Report eye-box matches at 0.5 intersection over
   union, usable top crops on single fish, incorrect crops in crowded trays,
   and eye proposals on fish-free photos. Tune the score and crop padding on
   validation. Measure upload failures separately, including the 5 MB limit.
2. **Model A input validation.** Test manual and YOLO crops separately, using
   real Tilapia eye and exposed-gill photos plus other species, hidden gills,
   unsupported framing, and non-fish lookalikes. Report false accepts by
   unsupported input type and false rejects by supported region. Select
   thresholds using validation data and verify them on a held-out batch.
3. **Model B freshness.** Use independently assessed freshness labels and
   record the assessment protocol and storage conditions. Keep the November 21
   two-fish group and its later photos in a single split. Leave unverified
   photos unlabeled for freshness. Evaluate eyes and gills separately and
   report the confusion matrix, per-class recall, and how often the label
   changes across slightly different crops of the same eye or gill. Compare
   consistent manual crops against YOLO crops on the same held-out fish to
   measure how much automatic cropping changes the final result.

Keep the feature opt-in while gathering these results. The one-epoch
checkpoint verifies that training and inference run, with the same photos
used for both. Use a separately evaluated checkpoint for the scanner release.

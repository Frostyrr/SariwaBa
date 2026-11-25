# Dataset image 0029.jpg: diagnostic findings

Date: 2026-10-30. No application code, model weights, or thresholds changed.

## Identity and runtime

The uploaded Downloads/0029.jpg is byte-identical to
`backend/datasets/tilapia/NonFresh/Day 4/Eyes/0029.jpg`.
Image: RGB, 1080 × 1920, no EXIF orientation tag.
SHA-256: `bded472ea0e68ee04f57b7a4c0e050582a115ac7aa5aa0b02290f593ef21179a`.

Loaded checkpoint SHA-256:
`5bf0eadfa1a79b490d9889253670819298daf8f1422f105abf99558af53883d1`.
Metadata: classes Fresh/NonFresh, image size 224, grouped_capture_split,
validation_accuracy 100.0. This validation metric is not a test-set guarantee.

## Experiments

| Path | Predicted label | Confidence | Outcome |
|---|---|---|---|
| Original JPEG, direct HTTP multipart upload | Rejected response omits label | 65.1531% | HTTP 400 LOW_CONFIDENCE |
| Same original, direct model invocation | Not Fresh | 65.1531% | Below API threshold |
| Pillow JPEG re-encode at quality 90 | Not Fresh | 61.4203% | Below API threshold |
| Pillow JPEG re-encode at quality 95 | Not Fresh | 64.4819% | Below API threshold |
| Pillow JPEG re-encode at quality 85 | Not Fresh | 67.1597% | Below API threshold |

The frontend requests maxWidth/maxHeight 1920 and imageQuality 90. The original
already fits those dimensions. Recompression plausibly explains the reported
61.7%, but Pillow is not the Android encoder and the actual phone upload bytes
were not captured, so this is not an exact reproduction of that number.

Training evaluation preprocessing was executed from train_grouped.py and compared
with predict.py on the same image. Maximum absolute tensor difference: **0.0**.
Both use RGB input, Resize((224,224)), ToTensor, and identical ImageNet normalization.
Training adds random augmentation; evaluation and inference correctly omit it.
There is no demonstrated preprocessing mismatch or EXIF orientation discrepancy.

Reconstructing the grouped split with the current dataset and script (seed 42)
places this image in test_indices. The checkpoint does not persist the original
split manifest, so this is reconstructed membership, not proof of historical
membership if dataset contents have changed since training.

## Conclusion and follow-up

The original image already produces a below-threshold score without Flutter.
The model's leading class agrees with the dataset's NonFresh label, but the API
rejects scores below 0.80. Frontend recompression can further change confidence;
backend resizing is consistent with the checked training evaluation pipeline.

For reproducible dataset checks, preserve original gallery-upload bytes and compare
their hash with the server input. Assess held-out accuracy, rejection rate, and
confidence calibration before selecting a threshold; no threshold-calibration
implementation was found in the inspected ML scripts. Do not lower the threshold
or change to a crop solely to make this sample pass. Persist split manifests and
checkpoint provenance for future comparisons.

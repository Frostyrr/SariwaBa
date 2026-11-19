# Tilapia input validation and freshness assessment

## Current behavior

The API now follows this sequence:

1. Validate the file type, size, dimensions and decodeability.
2. Run a separate MobileNetV3-Small supported-input validator.
3. Reject unsupported inputs, uncertain content, or a mismatch with the selected Eye/Gill region.
4. Run the existing freshness model only after the input gate passes.
5. Abstain if the freshness score is below `FRESHNESS_MIN_CONFIDENCE` (default 0.80).
6. Save successful authenticated results together with validation provenance.

The 0.80 freshness threshold is a provisional abstention policy, **not a calibrated
probability of correctness**. Choose a final threshold on validation data and report
both coverage and errors on a separate test set. A low score is not proof that a
photo is blurry, and an uncertain result is not a Not Fresh prediction.

There is no automatic blur detector. Input validation scores and freshness scores
measure different decisions and must not be substituted for each other.

Tilapia remains the intended scope. The three validator classes are `eye`, `gill`,
and `unsupported`, with supported examples coming from Tilapia. Other-species
eye/gill close-ups must be represented among unsupported examples. Passing this
gate provides evidence of a supported input; the API deliberately does not claim
an independent species identification (`species_verified` is false).

## Availability and migration

The existing freshness checkpoint is preserved. No validator has been trained or
activated by this change. **Until an evaluated validator checkpoint is installed,
valid image uploads return HTTP 503 `MODEL_UNAVAILABLE`; freshness inference does
not run.** There is no silent bypass or fallback to freshness-only classification.

From `backend`:

```powershell
.venv/Scripts/python.exe manage.py migrate
```

Migration 0004 adds a JSON validation field to history and an assessment-rejection
telemetry status. Existing records remain unverified; the migration does not
retroactively endorse their input content.

Content rejections return HTTP 422 with `UNSUPPORTED_IMAGE`, `CONTENT_UNCERTAIN`,
or `REGION_MISMATCH`. Freshness abstention returns `FRESHNESS_UNCERTAIN`.
Model/infrastructure failures remain technical errors rather than rejected fish.
Rejected requests create telemetry but no classification-history row or image.

## Dataset provenance and inventory

The project owner identified the source of the initial `datasets/tilapia` images as
[Tilapia Fresh and Non Fresh Image Dataset, Haripriya Sanga on Kaggle](https://www.kaggle.com/datasets/haripriyasanga/tilapia-fish-fresh-and-non-fresh-species).
The local folders contain Day 1–4 imagery under Fresh/NonFresh. The source page's
collection notes could not be retrieved by the available automated reader on
2026-11-19. Specimen identities, repeated captures across days, storage conditions,
label-assignment method, and dataset license remain unverified. Do not infer these
from the dataset title, folder names, or other papers that reuse the dataset.

Current local manifest inventory:

| Class | Images |
|---|---:|
| Eye | 3,606 |
| Gill | 2,058 |
| Unsupported | 31 |

The 31 unsupported images comprise 12 other-fish-species images, 3 whole-fish
images, and 16 wrong-region images. Folder categories are provisional labels,
not verified annotations. They were added to the validator/split manifests without
changing existing images, positive labels, or assignments. All 5,695 split rows
remain unassigned. The freshness manifest contains 5,664 positive examples.

Missing negatives include unrelated objects and representative poor captures.
Review whether the other-species examples actually contain close-ups of eyes and
gills; whole-fish negatives alone do not establish species discrimination.

## Review the data before training

`datasets/metadata/validator_labels.csv` records content labels and negative categories.
`freshness_labels.csv` records freshness labels for supported images.
`splits.csv` is the review worksheet. Preserve one row per image.

For each row in `splits.csv`:

- Set `specimen_id` to a globally consistent fish identity across both regions,
  freshness states, and days. Positive images require this field.
- Set `group_key` to the reviewed capture/source group. The current generated
  leaf-folder and 50-frame-block groups are provisional, not verified identities.
- Assign `split` as `train`, `val`, or `test` while keeping every specimen and
  capture/source group wholly in one partition.
- Set `split_status` to `verified` only after reviewing that assignment.

If Kaggle lacks specimen identities, do not invent independent fish from numbered
frames. A conservative alternative is to keep the entire unknown Kaggle cohort in
one partition with one exclusion-group identifier in both `specimen_id` and
`group_key`, then collect independent fish/capture groups for the other partitions.
Document that the cohort identifier is a conservative grouping, not a recovered
biological identity. It is not possible to establish independent test performance
by randomly splitting repeated frames from unidentified fish.

Add more diverse negatives with their source/capture group recorded. Check the
Fresh/NonFresh labels against the source method before making biological claims.

Inventory updates append newly discovered images and preserve manual assignments:

```powershell
.venv/Scripts/python.exe -m ml.validator_data --refresh
.venv/Scripts/python.exe -m ml.validator_data --audit
```

The audit rejects unreviewed assignments, specimens/capture groups crossing
partitions, unsafe paths, and byte-identical images crossing partitions. It cannot
recover hidden specimen identities or detect every visually similar image.

## Train and evaluate a candidate

```powershell
.venv/Scripts/python.exe -m ml.train_validator --output-dir ml/candidates/validator-v1
```

Training uses the reviewed CSV partitions, class-weighted loss and augmentation.
The frozen backbone retains its evaluation-mode normalization statistics.
The best epoch is selected by validation macro recall. The acceptance threshold
is selected only on validation data to maximize mean correct acceptance of both
regions subject to the configured unsupported false-accept target (default 5%).
The test set does not select the epoch or threshold.

By default each evaluation partition requires at least 20 images of **each** class,
plus training examples. The current 31 unsupported photos cannot satisfy that
minimum for both validation and test; more negatives are necessary. Twenty images
is an engineering floor, not a statistically sufficient sample-size claim.

The candidate directory contains `sariwaba_validator.pth` and `evaluation.json`,
including confusion matrices, false acceptance, per-region correct acceptance,
rejection and wrong-region counts, manifest hashes, and exploratory combined
freshness outcomes. Review per-source/category failures as well as aggregate rates.

The existing freshness checkpoint does not preserve original split membership.
Therefore combined scores involving that checkpoint are marked **exploratory**:
some validator-test images may have been used to train the freshness model.
A defensible final evaluation requires retraining freshness on the same reviewed
partitions or collecting a wholly independent test cohort unseen by both models.
The older `train.py` and `train_grouped.py` scripts do not consume the reviewed
CSV partitions and must not be used to claim this shared-partition evaluation.

No active weights are overwritten during training. To activate a reviewed
candidate, copy its checkpoint to `backend/ml/models/sariwaba_validator.pth` and
restart the backend. The runtime loader checks class ordering, scope, preprocessing,
threshold provenance and the checkpoint's held-out acceptance policy. It refuses
candidates whose reported test false-accept rate exceeds their configured target,
or that accept no correct examples of either supported region. These checks do
not replace manual review of dataset provenance, coverage and report quality.

## Verification commands

```powershell
# Repository root
backend/.venv/Scripts/python.exe backend/manage.py test classification authentication --noinput

# frontend
flutter test test/validation_contract_test.dart test/classification_upload_test.dart test/guest_history_test.dart test/model_aligned_ui_test.dart
```

Tests verify gate ordering, abstention, no saved results for rejected inputs,
missing-model behavior, history/cache provenance, legacy records, calibration,
and partition leakage checks. Mocked tests are implementation checks, not evidence
that a trained validator can distinguish Tilapia or assess freshness accurately.

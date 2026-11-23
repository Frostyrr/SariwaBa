# Model-aligned classification UI

## Scope and contract

The classification endpoint returns `label`, `confidence`, `scan_id`, and `saved`.
History also provides image and timestamp metadata. The model supports Fresh and
Not Fresh predictions. It does not return grades, species, body-part measurements,
food-safety approval, or cooking/storage advice.

## Implementation

1. Use a shared result card for predicted label and model confidence. Explain that
   confidence is a prediction score, not a freshness percentage or overall accuracy.
   Retain live result save status and the scan-again action.
2. Remove generated grades, eye/gill/scale assessments and recommendations from the
   result model. Match labels explicitly; missing labels must not become Fresh.
3. Replace illustrative dashboard charts and fallback metrics with available-history
   counts, mean confidence, and monthly counts. Show empty states and exclude
   undated scans from monthly groups with an explanation. Keep unknown labels separate.
4. Label the landing preview as an example. Describe online image classification,
   confidence, and account history without unsupported feature claims.
5. Preserve the existing theme, use wrapping text and labelled indicators, and test
   375, 768, 1024, and 1440 pixel layouts at normal and enlarged text sizes.

## Validation

- Flutter analysis and focused regression tests for label mapping, empty summaries,
  actual history counts, timestamp handling, and responsive result/summary cards.
- This change requires no backend API modification.
- Upload MIME type, physical-phone network configuration, and mobile login-first
  routing are separate integration tasks; this change is limited to result fidelity.
- Counts describe the history available to the client, not population statistics or
  validated model performance. Guest history is limited to the locally cached scans.

## Design guidance

Applied the requested ui-ux-pro-max skill's accessible presentation and Flutter
constraint-based layout guidance. Retained the existing brand theme rather than
introducing a new palette or marketing-style comparison layout.

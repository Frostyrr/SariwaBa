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

## Scanner workspace implementation plan

Proposed 24 November 2026. The goal is to let someone check a close-up
without opening the editor and identify the exact fish before checking a
whole-fish photo. The existing result display and photo validation rules
provide the starting point.

### Layout and reading order

| Screen | Layout |
| --- | --- |
| Wide workspace | Left column has Scanner, then Audit History. Right column has Detected Eyes, then Freshness Result, in one current-scan panel. |
| Narrow workspace | Stack Scanner, Detected Eyes, Freshness Result, then Audit History. Use a horizontal strip for eye thumbnails so the user can compare options. |

Use the existing workspace breakpoint as a starting point and check the
available panel width with the dashboard sidebar open. The desktop gallery
should show multiple thumbnails at once. Each tile and matching marker on
the original image gets the same number. Make the selected eye recognizable
through an outline, a label, and a selected state that assistive tools can read.
The gallery only appears when there are proposals.

### User flow

1. **Open the scanner immediately after taking or uploading a photo.** Show
   the original in the workstation. Keep Eye and Gill visible. Offer
   **Check freshness** for a ready close-up and **Adjust crop** for edits.
   Use the existing full-photo submission path for a direct check.
2. **Make Find Eye an explicit action in Eye mode.** Show progress beside the
   button. Keep the original visible and enable manual cropping if detection
   fails. Gill mode uses the manual or full-photo path. If the backend says
   the original is already an eye close-up, keep it ready for checking.
3. **Show the proposals alongside the original.** In desktop use a small
   thumbnail grid. On mobile use a scrollable strip. Tap an eye thumbnail
   to highlight its matching marker, or tap a marker to select its thumbnail.
   A single proposal can be preselected for preview. With several proposals,
   wait for the user to choose. Selecting an eye never starts classification.
4. **Show the exact crop before submission.** Check freshness sends the
   selected crop bytes through the existing validation and classification
   endpoint. If the user adjusts the crop, the edited image becomes the
   submitted image. Show the analyzed crop beside the result and label the
   percentage **Model confidence**.
5. **Keep recovery local to the current photo.** If no usable crop comes
   back, show **Adjust crop** and **Retake photo**. If there is a connection
   failure, offer **Retry** and keep the image. For a region mismatch, offer
   the matching Eye or Gill option and keep the image. A whole-photo
   rejection can point users to Find Eye or manual crop where applicable.

### Implementation order

| Step | Change |
| --- | --- |
| 1. Move the dashboard cards | In InspectionWorkspaceSection, put Audit History beneath Scanner and create the current-scan panel on the right. Move the result out of ScannerWorkstationCard into that panel. Preserve existing result details, guest or signed-in save behavior, and history actions. |
| 2. Share the scan selection | In ClassificationController, store the proposal list, detection status, and selected proposal for the current image. Use the existing proposal bytes, normalized rectangle, and eye center. The scanner and gallery read the same selection. |
| 3. Replace the proposal dialog | Render the proposal gallery in the workspace. Use the normalized rectangle against the actual displayed image bounds, accounting for letterboxing. Keep the crop modal as an optional manual editor and open it at the selected rectangle when available. |
| 4. Guard requests and results | Ignore Find Eye responses from a replaced image or changed region. Clear the live result when the selected crop changes, while retaining completed scans in Audit History. Prevent a late response from attaching to a different crop. Disable duplicate submissions while checking. |
| 5. Verify the scan paths | Run the focused Flutter suites and test the running app on desktop and mobile. Compare the behavior below with the current flow. |

The first pass reuses the existing backend contract. YOLO proposes crops,
Model A validates the submitted image, and Model B classifies accepted
close-ups. Every published result belongs to one submitted crop.

### Acceptance checks

- **Direct eye and gill photos:** The preview opens immediately. A usable
  close-up can be checked without opening the crop editor. Gill mode never
  calls the eye proposal endpoint.
- **Four-fish regression photo:** Find Eye displays the four verified
  proposals when the local backend returns them. Tapping a marker or
  thumbnail updates its counterpart. The bytes submitted and the result
  thumbnail both match the chosen eye.
- **Single eye or no eye found:** One suggested eye can be previewed with
  one selection. An empty response leaves manual crop available. An
  unsupported image still cannot reach freshness classification.
- **State and recovery:** Replacing the photo, changing region, or selecting
  another eye clears incompatible state. Simulate a slow response and a
  request failure. Retry keeps the current image and does not duplicate
  requests or history entries.
- **Desktop and mobile:** Verify the card order, scrolling, keyboard focus,
  touch targets, and enlarged text. The scanner and gallery remain usable
  together during normal eye selection.

Start with upload_region_flow_test.dart, classification_upload_test.dart,
and responsive_image_upload_zone_test.dart. Add a focused gallery test that
checks the selected proposal's bytes reach the classification request and
that switching eyes clears the live result. For manual verification, use the
four-fish photo, a clear eye, a gill photo, and an unsupported photo.

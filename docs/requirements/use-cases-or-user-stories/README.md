# Use cases and user stories

Source: Activity 5, Part E, draft v1.1. The summaries below retain the user goals while making the explicitly confirmed Guest permission visible. See `../review-notes/README.md` for discrepancies that still need correction in the source PDF.

| ID | Actor | Goal and trigger | Expected result |
| --- | --- | --- | --- |
| UC-01 | Consumer, Vendor | Select **Sign In with Google**. | Flutter obtains a Google ID token; Django verifies it for access to protected resources. |
| UC-02 | Guest, Consumer, Vendor | Capture one still fish image or select an existing JPEG/PNG image. | Flutter previews the image and validates format and size before submission. |
| UC-03 | Guest, Consumer, Vendor | Submit the selected image for freshness classification. | Django returns `Fresh` or `Not Fresh` and confidence; Flutter shows the result and disclaimer. |
| UC-04 | Consumer, Vendor | Complete an authenticated classification. | Django saves a record owned by that user and returns a non-null `scan_id`. |
| UC-05 | Consumer, Vendor | Open History or a scan detail. | Only that user's saved records are listed or displayed. |
| UC-06 | Consumer, Vendor | Confirm deletion of an owned scan. | Django removes the record and returns HTTP 204; the list updates. |
| UC-07 | Consumer, Vendor | Open Profile and edit the display name. | Django returns the user's profile and accepts a valid update. |

**Guest boundary:** A guest may complete UC-02 and UC-03 but not UC-04 through UC-07. A guest result has `scan_id: null`, creates no history row, and is not retroactively saved after sign-in.

**Alternate paths to show in the UI:** rejected file or size; denied camera access with upload fallback; sign-in failure; classification/network error with safe retry; inaccessible or missing history record; failed profile save or deletion. New classification requires a connection to Django.

The diagram embedded in the source PDF should be treated as a draft figure: its colored actor symbols need visible role labels and its links should be checked against the permission matrix before final export. Keep the editable diagram source with the final PNG when available.

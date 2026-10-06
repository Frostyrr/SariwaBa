# SariwaBa? requirements

**Baseline:** Version 1.1 (draft proposal), dated October 4, 2026.  
**Status:** Requires revision; official instructor review is pending. This repository package organizes the completed Activity 5 worksheet but is not an approved requirements baseline.

## Contents

- `system-requirements-specification.pdf` — the Activity 5 SRS/worksheet source, retained without changing its content.
- `requirements-to-feature-matrix.xlsx` — a working copy of the Part H traceability matrix.
- `use-cases-or-user-stories/` — use-case summaries and diagram review notes.
- `role-permission-matrix/` — Guest, Consumer, and Vendor access rules.
- `scope-and-constraints/` — included/excluded capabilities, architecture, and measurable targets.
- `review-notes/` — open issues and the review record.

## Current decision baseline

Guests may capture or upload one fish image, classify it through the Django backend, and see a temporary result; guest scans are not saved. Signed-in Consumers and Vendors may classify and save scans, manage only their own history, and view/update their profiles. Google OAuth 2.0/OpenID Connect is the sole external service. MobileNetV3 runs inside Django; PostgreSQL is reached only through Django ORM. Continuous video inference and offline ML classification are out of scope.

Use the requirement IDs `FR-001`–`FR-008` and `NFR-001`–`NFR-004` when linking UI designs, tests, and implementation tasks. Do not claim that an acceptance criterion has passed until evidence exists.

## Next review

Resolve the open items in `review-notes/README.md`, update the source SRS and matrix together, then record the reviewer, date, decision, and new baseline version. The Activity 6 UI flow should cite these requirement IDs, but must not treat draft status as instructor approval.

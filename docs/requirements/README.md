# SariwaBa? requirements

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

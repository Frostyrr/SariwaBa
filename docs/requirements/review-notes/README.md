# Requirements review notes

**Baseline under review:** Activity 5 v1.1 (draft proposal), October 4, 2026.  
**Recorded source status:** Requires revision. The PDF names MIT Jean Y. Villasin as consultation source, but says official instructor review is pending. No approval is claimed here.

| ID | Finding | Impact | Proposed action | Status |
| --- | --- | --- | --- | --- |
| R-01 | UC-02 lists only Consumer/Vendor, although FR-002 and the role matrix allow Guest image selection. | Activity 6 role traceability | Add Guest to UC-02 in the source SRS. | Open |
| R-02 | UC-04 is about saving a scan, but its expected-result cell describes `GET /api/v1/history/`. | Wrong acceptance test | Replace with authenticated database persistence and non-null `scan_id`; leave GET to UC-05. | Open |
| R-03 | NFR-003 says all endpoints are secured by Bearer tokens, while Guest classification is permitted. | API authorization ambiguity | State that protected endpoints require a verified token; classification permits unauthenticated requests with no persistence. | Open |
| R-04 | The embedded use-case diagram's colored actor symbols lack readable Guest/Consumer/Vendor labels. | Diagram cannot be reliably interpreted | Add visible actor names and verify all actor-to-use-case links. Export readable PNG and editable source. | Open |
| R-05 | Part F repeats the disclaimer business rule twice. | Minor document duplication | Remove one duplicate when revising the SRS. | Open |
| R-06 | Part A cites market observations, buyer reports, and initial user feedback without attached evidence in this package. | Source credibility | Add actual notes/citations or relabel them as planning assumptions. | Open |
| R-07 | The `<3 seconds` response target and `>85%` accuracy target lack a specified network/test dataset protocol. | Verification ambiguity | Define representative device, network, sample size, and evaluation dataset before acceptance testing. | Open |

The repository summaries for UC-02 and UC-04 reflect the team's stated intended behavior; the original PDF remains unchanged so these corrections are visible rather than silently presented as approved. Record the actual reviewer, review date, decisions, and revised baseline version after consultation.

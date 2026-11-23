# Manual Eye/Gill defense test sheet

Run on November 20, 2026 using the Django multipart upload endpoint and the real
local demo checkpoints. Experimental Model A was enabled and Model B used
its configured 0.80 score threshold. Requests used the guest path.
Telemetry database writes were intercepted. Freshness calls were counted with a
wrapper around the real model. This run covered API behavior from upload onward.
Flutter camera capture, real-device cropping, and persistence were outside this
run. The two user eye crops were generated in memory for diagnostic requests.

## Decision

**The current demo fails the zero-non-fish-results requirement on this set.**
`unrelated3.png` submitted as Eye reached Model B and returned Fresh with a 99.1%
freshness model score. That score describes the freshness model output for the
submitted image.

| Expected input | Requests | Reached freshness | Returned freshness label |
|---|---:|---:|---:|
| Eye with Eye selected | 5 | 2 | 2 |
| Gill with Gill selected | 5 | 3 | 2 |
| Eye or gill with the opposite selection | 10 | 0 | 0 |
| Unrelated objects (five photos in both modes) | 10 | 1 | 1 |
| Other fish species, wrong regions, and whole fish from challenge folders | 30 | 0 | 0 |
| Two user whole-fish photos | 2 | 0 | 0 |
| Two diagnostic user eye crops | 2 | 1 | 1 |

The challenge folder labels serve as expected input categories. The five unrelated
images are existing challenge examples. The same photo submitted in both modes
counts as two requests. These results do not estimate real-world false acceptance
or freshness accuracy. Independently scored freshness labels were unavailable.

For a device rehearsal, start with `testing_eye2.png` (Eye),
`testing_gills2.png` (Gill), and `unrelated3.png` (Eye). Confirm the exact preview
or close-up submitted, record the error code or result, and add unfamiliar
non-fish photos. Retain the false acceptance as a regression case when tuning
Model A.

## Request log

| Category | Photo | Selection | HTTP | Model B ran | Outcome |
|---|---|---|---:|---|---|
| eye | testing_eye1.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| eye | testing_eye1.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| eye | testing_eye2.png | eye | 200 | Yes | Not Fresh (99.9%) |
| eye | testing_eye2.png | gill | 422 | No | REGION_MISMATCH |
| eye | testing_eye3.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| eye | testing_eye3.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| eye | testing_eye4.png | eye | 200 | Yes | Fresh (82.9%) |
| eye | testing_eye4.png | gill | 422 | No | REGION_MISMATCH |
| eye | testing_eye5.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| eye | testing_eye5.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| gill | testing_gills1.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| gill | testing_gills1.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| gill | testing_gills2.png | eye | 422 | No | REGION_MISMATCH |
| gill | testing_gills2.png | gill | 200 | Yes | Fresh (100.0%) |
| gill | testing_gills3.png | eye | 422 | No | REGION_MISMATCH |
| gill | testing_gills3.png | gill | 200 | Yes | Fresh (100.0%) |
| gill | testing_gills4.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| gill | testing_gills4.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| gill | testing_gills5.png | eye | 422 | No | REGION_MISMATCH |
| gill | testing_gills5.png | gill | 422 | Yes | FRESHNESS_UNCERTAIN |
| other_fish_species | testing_other_fish1.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| other_fish_species | testing_other_fish1.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| other_fish_species | testing_other_fish2.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| other_fish_species | testing_other_fish2.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| other_fish_species | testing_other_fish3.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| other_fish_species | testing_other_fish3.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| other_fish_species | testing_other_fish4.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| other_fish_species | testing_other_fish4.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| other_fish_species | testing_other_fish5.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| other_fish_species | testing_other_fish5.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated1.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated1.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated2.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated2.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated3.png | eye | 200 | Yes | Fresh (99.1%) |
| unrelated_objects | unrelated3.png | gill | 422 | No | REGION_MISMATCH |
| unrelated_objects | unrelated4.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated4.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated5.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated5.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| whole_fish | whole_fish1.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| whole_fish | whole_fish1.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| whole_fish | whole_fish2.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| whole_fish | whole_fish2.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| whole_fish | whole_fish3.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| whole_fish | whole_fish3.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| whole_fish | whole_fish4.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| whole_fish | whole_fish4.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| whole_fish | whole_fish5.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| whole_fish | whole_fish5.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region1.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region1.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region2.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region2.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region3.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region3.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region4.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region4.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region5.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region5.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| user_whole_fish | test.jpg | eye | 422 | No | UNSUPPORTED_IMAGE |
| user_eye_crop | test-crop.png | eye | 200 | Yes | Not Fresh (98.6%) |
| user_whole_fish | 20120530095223.jpg | eye | 422 | No | UNSUPPORTED_IMAGE |
| user_eye_crop | 20120530095223-crop.png | eye | 422 | No | UNSUPPORTED_IMAGE |

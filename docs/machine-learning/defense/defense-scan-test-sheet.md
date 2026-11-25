# Manual Eye/Gill Defense Scan Test Sheet

Updated 25 November 2026 using the Django multipart upload endpoint (`/api/v1/classify/`) against the locked active checkpoints (`validator-f10d30ceded6` at `0.85` acceptance threshold and balanced `sariwaba_mobilenetv3_best.pth`) in an isolated in-memory database.

## Summary & Scope Note

Compared with the earlier November 20 experimental run, the previous everyday-object false accept (`unrelated3.png`) is now **blocked (`422 CONTENT_UNCERTAIN`)**, valid Eye/Gill acceptance increased from `4/10` to **`6/10`**, and **`0/30`** opposite-region, wrong-fish-region, or whole-fish challenge requests reached Model B:

| Expected input | Requests | Reached freshness (Model B) | Returned `200` freshness label |
| --- | ---: | ---: | ---: |
| Eye with `eye` selected | 5 | 3 | 3 |
| Gill with `gill` selected | 5 | 3 | 3 |
| Eye or gill with opposite selection (`REGION_MISMATCH` / gate) | 10 | 0 | 0 |
| Everyday inanimate objects (`unrelated1–4`, both modes) | 8 | 0 | 0 |
| Close-up biological eyes of non-tilapia (`unrelated5.png` mammal eye & `testing_other_fish5.png` non-tilapia fish eye, `eye` mode) | 2 | 2 | 2 |
| Other fish species (`1–4` + `5` in `gill` mode), wrong fish regions (`1–5`), and challenge whole fish (`1–5`) | 30 | 0 | 0 |

**Important defense note (`species_verified: false`):** Model A verifies **anatomical region** (`eye` vs. `gill` vs. `whole_tilapia` vs. non-eye/gill `unsupported`). Inanimate objects, wrong body parts, and mismatched regions were blocked (`28/30` non-tilapia challenge requests). The only `2` accepted challenge cases (`unrelated5.png`, a macro mammal eye, and `testing_other_fish5.png`, a macro silvery fish eye, both when `eye` mode was selected) are genuine anatomical eye close-ups—illustrating why the API explicitly returns `"region_verified": true, "species_verified": false` rather than claiming independent species identification.

For a live demo rehearsal, reliable sample files in `backend/ml/challenge_images/` include:
- **Valid Eye (`200`):** `testing_eye3.png`, `testing_eye4.png`, `testing_eye5.png` (select `eye`)
- **Valid Gill (`200`):** `testing_gills1.png`, `testing_gills2.png`, `testing_gills5.png` (select `gill`)
- **Region Mismatch (`422 REGION_MISMATCH`):** `testing_eye3.png` with `gill` selected, or `testing_gills2.png` with `eye` selected
- **Unsupported Object (`422 UNSUPPORTED_IMAGE` / `CONTENT_UNCERTAIN`):** `unrelated1.png` – `unrelated4.png`
- **Whole Tilapia $\rightarrow$ Auto Eye Crop (`/api/v1/classify/eye-proposals/`):** Any whole-fish photo in `backend/datasets/local_collection_v2/day_01/whole/` (Fresh) or `day_03/whole/` (Not Fresh)

## Request Log (`60` Challenge Requests — 25 November 2026)

| Category | Photo | Selection | HTTP | Model B ran | Outcome |
| --- | --- | --- | ---: | --- | --- |
| eye | testing_eye1.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| eye | testing_eye1.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| eye | testing_eye2.png | eye | 422 | No | CONTENT_UNCERTAIN |
| eye | testing_eye2.png | gill | 422 | No | CONTENT_UNCERTAIN |
| eye | testing_eye3.png | eye | 200 | Yes | Fresh (98.7%) |
| eye | testing_eye3.png | gill | 422 | No | REGION_MISMATCH |
| eye | testing_eye4.png | eye | 200 | Yes | Fresh (86.5%) |
| eye | testing_eye4.png | gill | 422 | No | REGION_MISMATCH |
| eye | testing_eye5.png | eye | 200 | Yes | Fresh (97.8%) |
| eye | testing_eye5.png | gill | 422 | No | REGION_MISMATCH |
| gill | testing_gills1.png | eye | 422 | No | REGION_MISMATCH |
| gill | testing_gills1.png | gill | 200 | Yes | Fresh (62.6%) |
| gill | testing_gills2.png | eye | 422 | No | REGION_MISMATCH |
| gill | testing_gills2.png | gill | 200 | Yes | Fresh (71.8%) |
| gill | testing_gills3.png | eye | 422 | No | CONTENT_UNCERTAIN |
| gill | testing_gills3.png | gill | 422 | No | CONTENT_UNCERTAIN |
| gill | testing_gills4.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| gill | testing_gills4.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| gill | testing_gills5.png | eye | 422 | No | REGION_MISMATCH |
| gill | testing_gills5.png | gill | 200 | Yes | Not Fresh (87.4%) |
| other_fish_species | testing_other_fish1.png | eye | 422 | No | CONTENT_UNCERTAIN |
| other_fish_species | testing_other_fish1.png | gill | 422 | No | CONTENT_UNCERTAIN |
| other_fish_species | testing_other_fish2.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| other_fish_species | testing_other_fish2.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| other_fish_species | testing_other_fish3.png | eye | 422 | No | CONTENT_UNCERTAIN |
| other_fish_species | testing_other_fish3.png | gill | 422 | No | CONTENT_UNCERTAIN |
| other_fish_species | testing_other_fish4.png | eye | 422 | No | CONTENT_UNCERTAIN |
| other_fish_species | testing_other_fish4.png | gill | 422 | No | CONTENT_UNCERTAIN |
| other_fish_species | testing_other_fish5.png | eye | 200 | Yes | Fresh (97.6%) |
| other_fish_species | testing_other_fish5.png | gill | 422 | No | REGION_MISMATCH |
| unrelated_objects | unrelated1.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated1.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated2.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated2.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated3.png | eye | 422 | No | CONTENT_UNCERTAIN |
| unrelated_objects | unrelated3.png | gill | 422 | No | CONTENT_UNCERTAIN |
| unrelated_objects | unrelated4.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated4.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| unrelated_objects | unrelated5.png | eye | 200 | Yes | Fresh (58.6%) |
| unrelated_objects | unrelated5.png | gill | 422 | No | REGION_MISMATCH |
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
| wrong_fish_regions | wrong_region1.png | eye | 422 | No | CONTENT_UNCERTAIN |
| wrong_fish_regions | wrong_region1.png | gill | 422 | No | CONTENT_UNCERTAIN |
| wrong_fish_regions | wrong_region2.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region2.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region3.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region3.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region4.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region4.png | gill | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region5.png | eye | 422 | No | UNSUPPORTED_IMAGE |
| wrong_fish_regions | wrong_region5.png | gill | 422 | No | UNSUPPORTED_IMAGE |

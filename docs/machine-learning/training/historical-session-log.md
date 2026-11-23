# Historical Machine Learning Session Log

This log brings together the model work recoverable from Git, saved files, and earlier SariwaBa sessions. Dates identify the recorded session or the first known commit. Original execution dates are sometimes missing. See the [November 23 run record](../evaluation/model-training-and-test-record.md) for the latest detailed results.

## October 2026

| Date | Work | Evidence and limits |
| --- | --- | --- |
| Oct 22 | Original Model B freshness classifier | First saved in Git at `14fec77`. The trainer configured 15 epochs, batch size 16, and grouped captures during splitting. The file records 100% validation accuracy. The selected epoch, completed epochs, exact image list, and original command are unknown. |
| Oct 23 | First recorded Model B cross-validation | Git `0227005` preserves five fold results of 85.82%, 100%, 100%, 72.16%, and 99.83%, with a mean of 91.56%. The script configured five epochs per fold. Per-fold weights and terminal logs are missing. |
| Oct 26 | Revised Model B cross-validation and fold 4 diagnostic | Git `3f00d07` preserves a separate result set of 79.93%, 100%, 100%, 55.60%, and 98.32%, with a mean of 86.77%. The result tables cover 5,664 photos, compared with 5,719 in the first experiment. The fold 4 diagnostic script also configured five epochs. |
| Oct 30 | Archived evaluation files | Git `bed20bf` moved the latest cross-validation tables under the experiments folder and added a final confusion matrix. The matrix alone does not identify the exact model file or prove an additional training run. |

The separate random-split trainer in the code shows that the workflow existed. A run log or saved output would be needed to count it as a completed experiment.

## November 19 to 22

### Model A photo checker

| Run or session | What survives |
| --- | --- |
| Original three-category experiment | Git `c3181e3` first records the epoch 1 backup and epoch 10 best version. Both give 92.95% validation accuracy. Their validation F1 scores were 0.7929 and 0.7961. The trainer allowed up to 15 epochs. The two files could come from one run, and total completed epochs are unknown. |
| Four-category setup and smoke run | The session reported five epochs with 71 difficult unsupported examples such as trays, cloth, plastic, and utensils. The saved file identifies itself as a smoke-test model. It has no independent test score. Another 55 red-cloth images were added to the list later without an immediate training run. |
| Three Day 1, Day 2, and cumulative candidates | The saved files each record eight epochs. They were training-only candidates. The cumulative version used 925 photos, including 172 whole tilapia photos. It identified one previously blocked whole-fish photo, but the small diagnostic also found tradeoffs in close-up acceptance and rejection of other fish. |
| Four-category model promoted on Nov 22 | Git `7c24d78` records the same model file in the candidate and active locations. The model includes validation and test results. The existing guide attributes 12 completed epochs and selection of epoch 8 to an external log. The repository audit could not verify that log. |

The early three-category split was regenerated during integration. Its current files cannot establish exact historical image membership.

### Model B freshness classifier

| Candidate | What the session reported |
| --- | --- |
| Initial Day 1 and orientation-corrected Day 1 | Two files were saved. The corrected run was reported as one epoch with 13 added close-ups and 97.14% accuracy on the existing test split. The initial run's completed epochs are unknown. |
| Expanded Day 1 | Three epochs were reported with 30 added close-ups and 91.02% on the existing test split. |
| Combined Day 1 and Day 2 | Three epochs were reported with 30 added close-ups and 94.80% on the existing 980-photo test split. Thirteen Day 1 images used seller-reported Fresh labels, while 17 Day 2 images used family-reported Fresh labels. The Day 2 fish had already contributed to development. |

All four saved candidates recorded epoch 1 as the selected epoch. The completed epoch counts above come from the session record where available. These versions remained experimental. The original active file stayed in use until the November 23 switch.

### Model C eye finder

| Run directory | Recorded epochs | Evaluation context |
| --- | ---: | --- |
| `smoke_v4` | 1 | Pipeline smoke check using training photos for validation. |
| `smoke_v4_gpu` | 1 | GPU smoke check using training photos for validation. |
| `candidate_v4_20ep` | 20 | Used 26 photos for both training and validation. At the app settings, the diagnostic matched 27 of 60 annotated eyes and reported 72 false-positive proposals. |
| `candidate_expanded_20ep` | 20 | Expanded training collection. Validation reused training images. |
| `candidate_day02_20ep` | 20 | Day 1 and 2 combined experiment. A session diagnostic matched 45 of 46 labeled eyes on familiar training trays. An earlier version was applied in the local app. |
| `retrained_day02_50ep_clean` | 50 | Used 155 training photos and 50 separate validation photos. No exact image overlap was found. These sets still included photos of the same local fish. It later became the baseline for the Day 3 update. |

### Software and image diagnostics

- **Nov 20 API rehearsal.** One unrelated photo reached the freshness model and was called Fresh at 99.1% confidence under the earlier demo configuration. Only two of five eye requests and two of five gill requests produced freshness labels. This tested the upload endpoint and exposed a photo-checking failure. It did not measure freshness accuracy. See the [request log](../defense/defense-scan-test-sheet.md).
- **Nov 21 upload flow.** The crop editor was changed to open without automatically running eye detection. This let the user select Gill before submitting. Two focused Flutter regression tests passed. Three failures in the broader suite also occurred with the old code.
- **Nov 21 crop sensitivity.** Different crops of one eye photo gave different freshness predictions. A 240 px crop produced Not Fresh at 72.7%, while a 252 px crop produced Fresh at 63.6%. Repeating the same crop gave the same result. This is a single-photo diagnostic.
- **Whole-fish routing.** An earlier check showed that Model A could block a whole-fish photo even when direct YOLO testing found the eye. This distinction matters when comparing the detector with the full upload flow.
- **Data preparation.** The Day 2 Roboflow export had 156 annotated images, including 13 that matched Day 1 images. The working copy removed repeats and aligned the class numbers with the app. An earlier split audit also raised a concern about photos from one market visit appearing across splits. Different filenames and group labels do not establish separate fish.

## November 23

| Work | Result |
| --- | --- |
| Model A update | Six epochs, selected epoch 3. Tested on 279 photos. It improved whole-fish routing but let more unsuitable photos through. The earlier Model A stayed active. |
| Model B update | Six epochs, selected epoch 2. On 390 test photos, accuracy rose from 70.26% to 96.67%. It called 0 of 214 Not Fresh test photos Fresh, compared with 108 for the earlier model. The Day 3 version was applied locally. |
| Model C update | Fifteen epochs, including a resume after the GPU stopped during epoch 10. The saved manifest records 155 earlier and **156 original Day 3** training images, 50 earlier validation images, and **171 separate original Day 3** test images. An earlier planning chat suggested test-only use for Day 3. The completed run used both subsets. The resulting detector was applied locally. |
| Backend checks | All 51 classification tests passed before the YOLO switch. The active detector produced eye proposals on all ten activation samples. The backend passed its readiness check after restart. |
| New three-fish batch | `local_collection_v2` was used for evaluation. Model A accepted 89 of 119 eye close-ups. The annotated YOLO test covered 75 images and 74 labeled eyes, with 97.31% precision, 97.69% recall, and 97.41% mAP50 for the eye class. The active model files were unchanged by this evaluation. |

The original Day 3 training and test images may show some of the same fish. The second collection provides separate fish, although three fish remain a small sample. Its Model B predictions need confirmed freshness labels before they can be scored as accuracy.

## Where to verify the records

- [Latest training, test counts, equipment, and confusion matrices](../evaluation/model-training-and-test-record.md)
- [Methods and feature history](../methods/tilapia-validation-pipeline.md)
- [Revised cross-validation fold results](../../../backend/ml/experiments/results/fold_accuracies.csv)
- [Defense scan request log](../defense/defense-scan-test-sheet.md)
- Local YOLO run folders contain the epoch CSV files. The November 23 run also contains the dataset counts and checkpoint comparison.
- Earlier session records supplement the files where logs are missing. Some older commands, run durations, and original specimen assignments remain unknown.

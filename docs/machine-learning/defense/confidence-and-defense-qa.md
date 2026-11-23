# SariwaBa Defense Questions and Answers

This guide describes the local November 23 configuration. It uses the earlier four-category Model A and the Day 3 versions of Models B and C.

## How confidence is calculated

| Model | Where its score comes from | What the app does with it |
| --- | --- | --- |
| A Photo checker | The network outputs four raw scores for eye, gill, unsupported, and whole tilapia. Softmax converts them into scores that add up to 1. The largest score is the confidence for the selected category. | The active file sets a minimum of 0.85. The app applies the category and region rules as well. A confident whole-fish result asks for a close-up, and a confident gill result cannot pass as an eye. |
| B Freshness classifier | The network outputs two raw scores. Softmax converts them into Fresh and Not Fresh scores that sum to 1. The larger score becomes the prediction confidence. | The backend returns the selected label and score. Model A must have accepted the image first. Model B's prediction code chooses the larger score without a separate minimum. |
| C YOLO eye finder | YOLO scores each predicted box for its object class. These scores belong to individual boxes. They do not add up across the image. | The app requests eye boxes, uses a minimum detection score of 0.25, and returns crop proposals. The proposal endpoint does not expose the detector score as the freshness confidence. |

**What does 93% Fresh mean?** The classifier gave Fresh a score of 0.93 for that input. It is a score for the model's choice. Accuracy is measured across labeled examples. We have not established that 93% scores are correct 93% of the time.

**Do you average the three confidence scores?** No. Each model answers a different question. YOLO finds the eye, Model A checks the photo type, and Model B predicts freshness from the accepted close-up.

**Why are the cutoffs different?** The validator threshold was chosen with validation images to control which photos it accepts. YOLO's 0.25 cutoff filters proposed eye boxes before cropping. The two scores have different meanings. Neither cutoff is an accuracy result.

## Questions the panel may ask

**Why use eyes and gills?** The freshness training data was built around those close-ups. Whole-fish upload uses YOLO to find an eye for the same freshness model. A direct comparison would be needed to claim close-ups are more accurate than whole-fish classification.

**Why separate the models?** They solve distinct tasks: checking the input, locating an eye, and classifying freshness. We can evaluate where a scan failed and update each model separately.

**How did you split the data?** Training photos were used to learn. Validation photos were used to select the saved version or threshold. Test photos were used to measure performance. Photos of the same fish should stay together across days. The earlier YOLO splits may share fish. The three-fish second collection was reserved as a separate test batch.

**Did you use a confusion matrix?** Yes, for Models A and B. Each row is the expected label and each column the predicted label. For Model B, one cell is particularly relevant: the number of Not Fresh photos incorrectly called Fresh. On the 390-photo comparison, that count dropped from 108 to 0 out of 214 Not Fresh photos. The same candidate mislabeled 13 of 176 Fresh photos, up from 8.

**How did you measure YOLO?** We compared predicted boxes with boxes drawn in Roboflow. Precision measures how often predicted boxes matched. Recall measures how often labeled eyes were found. mAP50 summarizes detection across confidence levels when a predicted box and the reference box overlap by at least 50% of their combined area. mAP50–95 also tests stricter overlap requirements.

**What did the new batch tell you?** On 75 Day 1 whole-fish photos with 74 labeled eyes, YOLO scored 97.41% eye mAP50 and 47.42% eye mAP50–95. It generally found eyes, but box alignment had room to improve. The photos represent three fish. The larger photo count does not increase the number of fish tested.

**How many epochs did you train?** In the original Day 3 update, Model A completed 6 and selected epoch 3. Model B completed 6 and selected epoch 2. Model C completed 15 after resuming from a GPU interruption. An epoch is one pass through the training set. The test batch was not used to choose these versions.

**What equipment and software did you use?** The original collection used Android and iPhone photos. Roboflow was used to draw boxes. Training ran on Windows with Python, PyTorch, and an NVIDIA GeForce RTX 4050 Laptop GPU. YOLO used Ultralytics. The local app runs its Django backend in Docker.

**Can the app certify that a fish is safe to eat?** The current evidence covers predictions from images and their recorded labels. We did not test whether a prediction establishes food safety. Observation day provides context, and the label should reflect what the team recorded for that sample.

## Evidence and implementation

- [Training runs, equipment, confusion matrices, and test counts](../evaluation/model-training-and-test-record.md)
- [Model A scoring and input rules](../../../backend/ml/validator.py)
- [Model B confidence calculation](../../../backend/ml/predict.py)
- [YOLO crop proposal code](../../../backend/ml/eye_proposals.py)
- [API response and scan flow](../../../backend/classification/views.py)

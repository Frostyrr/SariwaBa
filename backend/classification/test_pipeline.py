import math
import tempfile
import io
from pathlib import Path
from unittest.mock import patch

from django.contrib.auth.models import User
from django.test import TestCase, override_settings
from rest_framework.test import APIClient

from classification.models import ClassificationHistory, ClassificationTelemetryLog
from classification.tests import _create_test_image
from ml.predict import ModelInferenceError, ModelUnavailableError
from ml.validator import VALIDATOR_V2_CLASSES, InputRejectedError, decide_input, get_validator_bundle
from ml.validator import validate_image
from PIL import Image
import torch
from torch import nn
from torchvision import models


class ValidatorDecisionTests(TestCase):
    def checkpoint(self):
        net = models.mobilenet_v3_small(weights=None)
        net.classifier[3] = nn.Linear(net.classifier[3].in_features, 3)
        with torch.no_grad():
            for parameter in net.parameters():
                parameter.zero_()
            net.classifier[3].bias.copy_(torch.tensor([5., 0., -5.]))
        return {"classes": ["eye", "gill", "unsupported"],
            "model_state_dict": net.state_dict(), "validation_scope": "tilapia_eye_gill",
            "threshold_source": "validation_split", "acceptance_threshold": 0.9,
            "image_size": 224, "model_version": "synthetic-fixture",
            "evaluation": {"acceptance_threshold": 0.9, "min_eval_per_class": 20,
                "target_false_accept_rate": 0.05,
                "test": {"unsupported_false_accept_rate": 0.,
                    "class_counts": {"eye": 20, "gill": 20, "unsupported": 20},
                    "supported_correct_accept_rate": {"eye": 1., "gill": 1.}}}}

    def test_checkpoint_load_and_real_tensor_inference(self):
        # Synthetic weights exercise integration, not biological accuracy.
        with tempfile.TemporaryDirectory() as directory:
            checkpoint_path = Path(directory) / "fixture.pth"
            torch.save(self.checkpoint(), checkpoint_path)
            with patch("ml.validator.VALIDATOR_PATH", checkpoint_path), patch("ml.validator._BUNDLE", None):
                data = io.BytesIO()
                Image.new("RGB", (128, 128), "gray").save(data, format="PNG")
                result = validate_image(data, "eye")
                self.assertTrue(result["region_verified"])
                self.assertEqual(result["validator_version"], "synthetic-fixture")

    def test_incompatible_or_failed_candidate_is_unavailable(self):
        for mutation in ("wrong_classes", "failed_test"):
            checkpoint = self.checkpoint()
            if mutation == "wrong_classes":
                checkpoint["classes"] = ["Fresh", "NonFresh"]
            else:
                checkpoint["evaluation"]["test"]["unsupported_false_accept_rate"] = 0.5
            with self.subTest(mutation=mutation), patch("ml.validator.torch.load", return_value=checkpoint):
                with self.assertRaises(ModelUnavailableError):
                    get_validator_bundle(force_reload=True)

    def test_supported_region_and_mismatch(self):
        result = decide_input([0.95, 0.03, 0.02], "eye", 0.9)
        self.assertTrue(result["region_verified"])
        self.assertFalse(result["species_verified"])
        with self.assertRaises(InputRejectedError) as error:
            decide_input([0.95, 0.03, 0.02], "gill", 0.9)
        self.assertEqual(error.exception.code, "REGION_MISMATCH")

    def test_unsupported_and_uncertain_are_distinct(self):
        for scores, expected in [([0.01, 0.02, 0.97], "UNSUPPORTED_IMAGE"),
                                 ([0.6, 0.3, 0.1], "CONTENT_UNCERTAIN")]:
            with self.subTest(expected=expected), self.assertRaises(InputRejectedError) as error:
                decide_input(scores, "eye", 0.9)
            self.assertEqual(error.exception.code, expected)

    def test_invalid_model_scores_fail_as_technical_errors(self):
        for scores in ([math.nan, 0, 1], [0.9, 0.9, 0.9], [0.5, 0.5]):
            with self.assertRaises(ModelInferenceError):
                decide_input(scores, "eye", 0.9)

    def test_missing_checkpoint_fails_closed(self):
        with tempfile.TemporaryDirectory() as directory:
            with patch("ml.validator.VALIDATOR_PATH", Path(directory) / "missing.pth"):
                with self.assertRaises(ModelUnavailableError):
                    get_validator_bundle(force_reload=True)


class PipelineAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.client.force_authenticate(User.objects.create_user(username="pipeline-test"))
        self.temporary_media = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary_media.cleanup)
        media_settings = override_settings(MEDIA_ROOT=self.temporary_media.name)
        media_settings.enable()
        self.addCleanup(media_settings.disable)

    def post(self):
        return self.client.post("/api/v1/classify/",
            {"image": _create_test_image(), "region_type": "eye"}, format="multipart")

    @patch("classification.views.predict_image")
    @patch("classification.views.validate_image")
    def test_content_rejection_never_runs_freshness_or_saves(self, validator, freshness):
        for code in ("UNSUPPORTED_IMAGE", "CONTENT_UNCERTAIN", "REGION_MISMATCH",
                     "WHOLE_TILAPIA_CLOSE_UP_REQUIRED"):
            with self.subTest(code=code):
                validator.side_effect = InputRejectedError(code, "Rejected", 0.7)
                response = self.post()
                self.assertEqual(response.status_code, 422)
                self.assertEqual(response.data["error"]["code"], code)
                self.assertNotIn("label", response.data)
        freshness.assert_not_called()
        self.assertFalse(ClassificationHistory.objects.exists())
        self.assertEqual(ClassificationTelemetryLog.objects.filter(status="REJECTED_ASSESSMENT").count(), 4)

    @patch("classification.views.predict_image", return_value={"label": "Fresh", "confidence": 0.9})
    @patch("classification.views.validate_image")
    def test_auto_uses_detected_gill_in_one_request(self, validator, freshness):
        validator.return_value = decide_input(
            [0.02, 0.94, 0.02, 0.02], "auto", 0.85, VALIDATOR_V2_CLASSES
        )
        response = self.client.post("/api/v1/classify/",
            {"image": _create_test_image(), "region_type": "auto"}, format="multipart")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["region_type"], "gill")
        validator.assert_called_once()
        self.assertEqual(validator.call_args.args[1], "auto")
        freshness.assert_called_once()
        self.assertEqual(freshness.call_args.kwargs["region_type"], "gill")
        self.assertEqual(ClassificationHistory.objects.get().region_type, "gill")

    def test_four_class_gate_routes_whole_fish_to_close_up_in_both_modes(self):
        for region in ("eye", "gill", "auto"):
            with self.subTest(region=region), self.assertRaises(InputRejectedError) as error:
                decide_input([0.02, 0.03, 0.02, 0.93], region, 0.8, VALIDATOR_V2_CLASSES)
            self.assertEqual(error.exception.code, "WHOLE_TILAPIA_CLOSE_UP_REQUIRED")

    def test_four_class_gate_accepts_supported_regions(self):
        for region, scores in (("eye", [0.91, 0.03, 0.03, 0.03]),
                               ("gill", [0.01, 0.94, 0.03, 0.02])):
            self.assertTrue(decide_input(scores, region, 0.8, VALIDATOR_V2_CLASSES)["region_verified"])

    @patch("classification.views.predict_image")
    @patch("classification.views.validate_image", side_effect=ModelUnavailableError("Validator unavailable"))
    def test_missing_validator_is_service_error(self, validator, freshness):
        response = self.post()
        self.assertEqual(response.status_code, 503)
        self.assertEqual(response.data["error"]["code"], "MODEL_UNAVAILABLE")
        freshness.assert_not_called()
        self.assertFalse(ClassificationHistory.objects.exists())

    @patch("classification.views.predict_image", return_value={"label": "Fresh", "confidence": 0.699})
    @patch("classification.views.validate_image", return_value={"region_verified": True})
    def test_accepted_input_returns_and_saves_freshness_estimate_below_old_cutoff(self, validator, freshness):
        response = self.post()
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.data["label"], "Fresh")
        self.assertEqual(response.data["confidence"], 0.699)
        self.assertEqual(ClassificationHistory.objects.get().confidence, 0.699)

    @patch("classification.views.predict_image", return_value={"label": "Fresh", "confidence": 0.94})
    @patch("classification.views.validate_image", return_value={
        "region_verified": True, "species_verified": False, "validator_version": "test-v1"})
    def test_order_and_validation_metadata_persist_through_history(self, validator, freshness):
        calls = []
        def gate(image, region):
            calls.append("gate")
            image.read()  # Verify the endpoint rewinds before freshness inference.
            return validator.return_value
        def classify(image, region_type):
            self.assertEqual(image.tell(), 0)
            calls.append("freshness")
            return freshness.return_value
        validator.side_effect, freshness.side_effect = gate, classify
        response = self.post()
        self.assertEqual(response.status_code, 200)
        self.assertEqual(calls, ["gate", "freshness"])
        self.assertNotIn("species", response.data)
        self.assertEqual(response.data["assessment_species"], "Tilapia")
        self.assertTrue(response.data["region_verified"])
        self.assertFalse(response.data["species_verified"])
        history = self.client.get("/api/v1/history/").data["history"][0]
        self.assertTrue(history["region_verified"])
        self.assertEqual(history["validator_version"], "test-v1")

    def test_old_history_does_not_gain_verification(self):
        ClassificationHistory.objects.create(user=self.client.handler._force_user,
            image="legacy.jpg", region_type="eye", label="Fresh", confidence=0.9)
        history = self.client.get("/api/v1/history/").data["history"][0]
        self.assertFalse(history["region_verified"])
        self.assertFalse(history["species_verified"])

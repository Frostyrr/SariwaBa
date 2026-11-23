import base64
import io
from unittest.mock import patch

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import SimpleTestCase
from django.urls import reverse
from PIL import Image
from rest_framework.test import APIClient

from ml.eye_proposals import DetectorUnavailable
from ml.validator import InputRejectedError


class EyeProposalTests(SimpleTestCase):
    def setUp(self):
        validator = patch("classification.views.validate_image")
        self.validator = validator.start()
        self.addCleanup(validator.stop)
        self.validator.side_effect = InputRejectedError(
            "WHOLE_TILAPIA_CLOSE_UP_REQUIRED", "Whole tilapia"
        )

    def upload(self, content=None):
        if content is None:
            image = io.BytesIO()
            Image.new("RGB", (100, 80), "gray").save(image, format="PNG")
            content = image.getvalue()
        return APIClient().post(
            reverse("eye-proposals"),
            {"image": SimpleUploadedFile("fish.png", content, "image/png")},
            format="multipart",
        )

    @patch("classification.views.propose_eye_crops")
    def test_returns_exact_crop_for_each_proposal(self, propose):
        propose.return_value = [
            ((20, 16, 60, 56), (0.35, 0.4)),
            ((60, 0, 90, 30), (0.75, 0.1)),
        ]
        response = self.upload()
        self.assertEqual(response.status_code, 200)
        proposals = response.json()["proposals"]
        self.assertEqual(len(proposals), 2)
        self.assertEqual(proposals[0]["rect"], [0.2, 0.2, 0.6, 0.7])
        self.assertEqual(proposals[0]["eye_center"], [0.35, 0.4])
        with Image.open(io.BytesIO(base64.b64decode(proposals[0]["crop_base64"]))) as crop:
            self.assertEqual(crop.size, (40, 40))

    @patch("classification.views.propose_eye_crops", return_value=[])
    def test_empty_result_keeps_manual_crop_available(self, _propose):
        self.assertEqual(self.upload().json(), {"proposals": []})

    @patch("classification.views.propose_eye_crops", side_effect=DetectorUnavailable)
    def test_unavailable_detector_returns_503(self, _propose):
        self.assertEqual(self.upload().status_code, 503)

    @patch("classification.views.propose_eye_crops")
    def test_invalid_image_never_reaches_detector(self, propose):
        self.assertEqual(self.upload(b"invalid").status_code, 400)
        propose.assert_not_called()
        self.validator.assert_not_called()

    @patch("classification.views.propose_eye_crops")
    def test_rejected_original_never_reaches_detector(self, propose):
        for code in ("UNSUPPORTED_IMAGE", "CONTENT_UNCERTAIN", "REGION_MISMATCH"):
            with self.subTest(code=code):
                self.validator.side_effect = InputRejectedError(code, "Rejected")
                response = self.upload()
                self.assertEqual(response.status_code, 422)
                self.assertEqual(response.json()["error"]["code"], code)
                propose.assert_not_called()

    @patch("classification.views.propose_eye_crops")
    def test_existing_eye_close_up_skips_detector(self, propose):
        self.validator.side_effect = None
        self.assertEqual(self.upload().json(), {"already_eye": True, "proposals": []})
        propose.assert_not_called()

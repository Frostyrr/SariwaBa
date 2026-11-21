import base64
import io
from unittest.mock import patch

from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import SimpleTestCase
from django.urls import reverse
from PIL import Image
from rest_framework.test import APIClient

from ml.eye_proposals import DetectorUnavailable


class EyeProposalTests(SimpleTestCase):
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
        propose.return_value = [(20, 16, 60, 56), (60, 0, 90, 30)]
        response = self.upload()
        self.assertEqual(response.status_code, 200)
        proposals = response.json()["proposals"]
        self.assertEqual(len(proposals), 2)
        self.assertEqual(proposals[0]["rect"], [0.2, 0.2, 0.6, 0.7])
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

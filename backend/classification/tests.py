import io
from pathlib import Path
from unittest.mock import patch

from django.contrib.auth.models import User
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase
from PIL import Image
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from ml.predict import ModelInferenceError, ModelUnavailableError
from .models import ClassificationHistory


def _create_test_image(
    format="JPEG",
    size=(128, 128),
    filename=None,
    content_type=None,
):
    file_obj = io.BytesIO()
    mode = "RGB" if format.upper() != "PNG" else "RGBA"
    image = Image.new(mode, size, color=(73, 109, 137))
    if mode == "RGBA" and format.upper() == "JPEG":
        image = image.convert("RGB")
    image.save(file_obj, format=format)
    file_obj.seek(0)
    ext = format.lower()
    return SimpleUploadedFile(
        filename or f"test_fish.{ext}",
        file_obj.read(),
        content_type=content_type or f"image/{ext}",
    )


class ClassificationAPITests(TestCase):
    """
    API validation, permission, error-handling, and persistence tests.
    Includes both mocked inference tests and real MobileNetV3 checkpoint tests.
    """

    def setUp(self):
        self.client = APIClient()

        # User 1
        self.user = User.objects.create_user(
            username="fisherman@sariwaba.ph",
            email="fisherman@sariwaba.ph",
        )
        refresh = RefreshToken.for_user(self.user)
        self.auth_header = f"Bearer {refresh.access_token}"

        # User 2
        self.other_user = User.objects.create_user(
            username="other@sariwaba.ph",
            email="other@sariwaba.ph",
        )

    # ------------------------------------------------------------------
    # Validation Error Tests
    # ------------------------------------------------------------------

    def test_missing_image_returns_400(self):
        response = self.client.post(
            "/api/v1/classify/",
            {"region_type": "eye"},
            format="multipart",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data["error"]["code"], "MISSING_IMAGE")

    def test_missing_or_invalid_region_type_returns_400(self):
        image1 = _create_test_image()
        resp_missing = self.client.post(
            "/api/v1/classify/",
            {"image": image1},
            format="multipart",
        )
        self.assertEqual(resp_missing.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            resp_missing.data["error"]["code"],
            "INVALID_REGION_TYPE",
        )

        image2 = _create_test_image()
        resp_invalid = self.client.post(
            "/api/v1/classify/",
            {"image": image2, "region_type": "tail_fin"},
            format="multipart",
        )
        self.assertEqual(resp_invalid.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            resp_invalid.data["error"]["code"],
            "INVALID_REGION_TYPE",
        )

    def test_empty_image_returns_400(self):
        empty_file = SimpleUploadedFile(
            "empty.jpg",
            b"",
            content_type="image/jpeg",
        )
        response = self.client.post(
            "/api/v1/classify/",
            {"image": empty_file, "region_type": "eye"},
            format="multipart",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data["error"]["code"], "EMPTY_IMAGE")

    def test_excessive_file_size_returns_400(self):
        oversized_file = SimpleUploadedFile(
            "huge.jpg",
            b"\xff\xd8\xff" + (b"0" * (5 * 1024 * 1024 + 10)),
            content_type="image/jpeg",
        )
        response = self.client.post(
            "/api/v1/classify/",
            {"image": oversized_file, "region_type": "gill"},
            format="multipart",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data["error"]["code"], "IMAGE_TOO_LARGE")

    def test_unsupported_format_and_spoofed_mime_returns_400(self):
        # 1. Explicit unsupported MIME type
        txt_file = SimpleUploadedFile(
            "notes.txt",
            b"not an image",
            content_type="text/plain",
        )
        resp_mime = self.client.post(
            "/api/v1/classify/",
            {"image": txt_file, "region_type": "eye"},
            format="multipart",
        )
        self.assertEqual(resp_mime.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            resp_mime.data["error"]["code"],
            "UNSUPPORTED_IMAGE_TYPE",
        )

        # 2. GIF bytes disguised with image/jpeg content_type and .jpg extension
        gif_file = _create_test_image(
            format="GIF",
            size=(128, 128),
            filename="spoofed.jpg",
            content_type="image/jpeg",
        )
        resp_spoofed = self.client.post(
            "/api/v1/classify/",
            {"image": gif_file, "region_type": "eye"},
            format="multipart",
        )
        self.assertEqual(resp_spoofed.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            resp_spoofed.data["error"]["code"],
            "UNSUPPORTED_IMAGE_TYPE",
        )

    def test_corrupted_image_returns_400(self):
        corrupted = SimpleUploadedFile(
            "corrupted.png",
            b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDRcorrupted_payload",
            content_type="image/png",
        )
        response = self.client.post(
            "/api/v1/classify/",
            {"image": corrupted, "region_type": "gill"},
            format="multipart",
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data["error"]["code"], "INVALID_IMAGE")

    def test_invalid_image_dimensions_returns_400(self):
        # Too small (< 32x32)
        tiny_image = _create_test_image(format="PNG", size=(16, 16))
        resp_small = self.client.post(
            "/api/v1/classify/",
            {"image": tiny_image, "region_type": "eye"},
            format="multipart",
        )
        self.assertEqual(resp_small.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            resp_small.data["error"]["code"],
            "INVALID_IMAGE_DIMENSIONS",
        )

        # Too large (> 4096 in one dimension)
        wide_image = _create_test_image(format="PNG", size=(4100, 64))
        resp_large = self.client.post(
            "/api/v1/classify/",
            {"image": wide_image, "region_type": "gill"},
            format="multipart",
        )
        self.assertEqual(resp_large.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(
            resp_large.data["error"]["code"],
            "INVALID_IMAGE_DIMENSIONS",
        )

    # ------------------------------------------------------------------
    # Mocked Model & Inference Failure Tests
    # ------------------------------------------------------------------

    @patch("classification.views.predict_image")
    def test_mocked_valid_classification_contract(self, mock_predict):
        mock_predict.return_value = {
            "classification": "Fresh",
            "label": "Fresh",
            "confidence": 0.94,
            "raw_label": "Fresh",
            "region_type": "gill",
        }
        image = _create_test_image(format="PNG")
        response = self.client.post(
            "/api/v1/classify/",
            {"image": image, "region_type": "gill"},
            format="multipart",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["classification"], "Fresh")
        self.assertEqual(response.data["label"], "Fresh")
        self.assertAlmostEqual(response.data["confidence"], 0.94)
        self.assertEqual(response.data["region_type"], "gill")
        self.assertIn("disclaimer", response.data)
        self.assertEqual(response.data["saved"], False)
        self.assertIsNone(response.data["scan_id"])

    @patch(
        "classification.views.predict_image",
        side_effect=ModelUnavailableError("Checkpoint missing."),
    )
    def test_model_unavailable_returns_503(self, _mock_predict):
        image = _create_test_image()
        response = self.client.post(
            "/api/v1/classify/",
            {"image": image, "region_type": "eye"},
            format="multipart",
        )
        self.assertEqual(
            response.status_code,
            status.HTTP_503_SERVICE_UNAVAILABLE,
        )
        self.assertEqual(response.data["error"]["code"], "MODEL_UNAVAILABLE")

    @patch(
        "classification.views.predict_image",
        side_effect=ModelInferenceError("Tensor runtime failure."),
    )
    def test_inference_exception_returns_500(self, _mock_predict):
        image = _create_test_image()
        response = self.client.post(
            "/api/v1/classify/",
            {"image": image, "region_type": "eye"},
            format="multipart",
        )
        self.assertEqual(
            response.status_code,
            status.HTTP_500_INTERNAL_SERVER_ERROR,
        )
        self.assertEqual(response.data["error"]["code"], "INFERENCE_FAILED")

    # ------------------------------------------------------------------
    # Guest vs Authenticated Persistence & History Tests (Real Model)
    # ------------------------------------------------------------------

    def test_guest_classification_does_not_save_scan(self):
        """Guest scans should return 200, classification/label, confidence, region_type, but scan_id: null and saved: False."""
        image = _create_test_image()
        response = self.client.post(
            "/api/v1/classify/",
            {"image": image, "region_type": "eye"},
            format="multipart",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn(response.data.get("classification"), ["Fresh", "Not Fresh"])
        self.assertEqual(response.data.get("region_type"), "eye")
        self.assertEqual(response.data.get("saved"), False)
        self.assertIsNone(response.data.get("scan_id"))
        self.assertEqual(ClassificationHistory.objects.count(), 0)

    def test_authenticated_classification_saves_scan_with_region_type(self):
        """Authenticated scans should automatically save to history with region_type and return non-null scan_id."""
        image = _create_test_image()
        response = self.client.post(
            "/api/v1/classify/",
            {"image": image, "region_type": "gill"},
            HTTP_AUTHORIZATION=self.auth_header,
            format="multipart",
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data.get("saved"), True)
        self.assertEqual(response.data.get("region_type"), "gill")
        self.assertIsNotNone(response.data.get("scan_id"))
        self.assertEqual(ClassificationHistory.objects.count(), 1)
        scan = ClassificationHistory.objects.first()
        self.assertEqual(scan.user, self.user)
        self.assertEqual(scan.region_type, "gill")

    def test_list_history_returns_only_own_records(self):
        """Users can only view their own scan histories, including region_type."""
        image1 = _create_test_image()
        image2 = _create_test_image()

        ClassificationHistory.objects.create(
            user=self.user,
            image=image1,
            region_type="eye",
            label="Fresh",
            confidence=0.98,
        )
        ClassificationHistory.objects.create(
            user=self.other_user,
            image=image2,
            region_type="gill",
            label="Not Fresh",
            confidence=0.88,
        )

        response = self.client.get(
            "/api/v1/history/",
            HTTP_AUTHORIZATION=self.auth_header,
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data.get("count"), 1)
        self.assertEqual(len(response.data.get("history")), 1)
        self.assertEqual(response.data.get("history")[0]["label"], "Fresh")
        self.assertEqual(response.data.get("history")[0]["region_type"], "eye")

    def test_history_detail_and_delete_permissions(self):
        """User can retrieve and delete their own scan, but cannot access others' scans."""
        image1 = _create_test_image()
        image2 = _create_test_image()

        own_scan = ClassificationHistory.objects.create(
            user=self.user,
            image=image1,
            region_type="eye",
            label="Fresh",
            confidence=0.95,
        )
        other_scan = ClassificationHistory.objects.create(
            user=self.other_user,
            image=image2,
            region_type="gill",
            label="Not Fresh",
            confidence=0.91,
        )

        # Retrieve own scan: 200 OK
        resp = self.client.get(
            f"/api/v1/history/{own_scan.scan_id}/",
            HTTP_AUTHORIZATION=self.auth_header,
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data.get("scan_id"), own_scan.scan_id)
        self.assertEqual(resp.data.get("region_type"), "eye")

        # Retrieve other's scan: 404 NOT FOUND
        resp = self.client.get(
            f"/api/v1/history/{other_scan.scan_id}/",
            HTTP_AUTHORIZATION=self.auth_header,
        )
        self.assertEqual(resp.status_code, status.HTTP_404_NOT_FOUND)

        # Delete own scan: 204 NO CONTENT
        resp = self.client.delete(
            f"/api/v1/history/{own_scan.scan_id}/",
            HTTP_AUTHORIZATION=self.auth_header,
        )
        self.assertEqual(resp.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(
            ClassificationHistory.objects.filter(
                scan_id=own_scan.scan_id
            ).exists()
        )

    def test_real_tilapia_dataset_eye_and_gill_inference(self):
        """
        End-to-end verification using real Tilapia eye and gill photographs
        against the actual trained MobileNetV3 checkpoint when dataset files are present.
        """
        base_dir = Path(__file__).resolve().parent.parent
        dataset_dir = base_dir / "datasets" / "tilapia"
        if not dataset_dir.exists():
            self.skipTest("Tilapia dataset directory not present.")

        eye_samples = list((dataset_dir / "Fresh").rglob("*Eyes*/*.jpg"))
        gill_samples = list((dataset_dir / "NonFresh").rglob("*Gills*/*.jpg"))

        if eye_samples:
            with open(eye_samples[0], "rb") as f:
                upload = SimpleUploadedFile(
                    eye_samples[0].name,
                    f.read(),
                    content_type="image/jpeg",
                )
            resp = self.client.post(
                "/api/v1/classify/",
                {"image": upload, "region_type": "eye"},
                format="multipart",
            )
            self.assertEqual(resp.status_code, status.HTTP_200_OK)
            self.assertIn(resp.data["classification"], ["Fresh", "Not Fresh"])
            self.assertEqual(resp.data["region_type"], "eye")
            self.assertGreater(resp.data["confidence"], 0.0)
            self.assertLessEqual(resp.data["confidence"], 1.0)

        if gill_samples:
            with open(gill_samples[0], "rb") as f:
                upload = SimpleUploadedFile(
                    gill_samples[0].name,
                    f.read(),
                    content_type="image/jpeg",
                )
            resp = self.client.post(
                "/api/v1/classify/",
                {"image": upload, "region_type": "gill"},
                format="multipart",
            )
            self.assertEqual(resp.status_code, status.HTTP_200_OK)
            self.assertIn(resp.data["classification"], ["Fresh", "Not Fresh"])
            self.assertEqual(resp.data["region_type"], "gill")
            self.assertGreater(resp.data["confidence"], 0.0)
            self.assertLessEqual(resp.data["confidence"], 1.0)

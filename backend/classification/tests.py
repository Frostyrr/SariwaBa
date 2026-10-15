import io
from PIL import Image
from django.contrib.auth.models import User
from django.core.files.uploadedfile import SimpleUploadedFile
from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from .models import ClassificationHistory


def _create_test_image(format="JPEG"):
    file_obj = io.BytesIO()
    image = Image.new("RGB", (100, 100), color=(73, 109, 137))
    image.save(file_obj, format=format)
    file_obj.seek(0)
    return SimpleUploadedFile(
        f"test_fish.{format.lower()}",
        file_obj.read(),
        content_type=f"image/{format.lower()}"
    )


class ClassificationAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()

        # User 1
        self.user = User.objects.create_user(
            username="fisherman@sariwaba.ph",
            email="fisherman@sariwaba.ph"
        )
        refresh = RefreshToken.for_user(self.user)
        self.auth_header = f"Bearer {refresh.access_token}"

        # User 2
        self.other_user = User.objects.create_user(
            username="other@sariwaba.ph",
            email="other@sariwaba.ph"
        )

    def test_guest_classification_does_not_save_scan(self):
        """Guest scans should return 200, label, confidence, but scan_id: null and saved: False."""
        image = _create_test_image()
        response = self.client.post(
            "/api/v1/classify/",
            {"image": image},
            format="multipart"
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data.get("saved"), False)
        self.assertIsNone(response.data.get("scan_id"))
        self.assertEqual(ClassificationHistory.objects.count(), 0)

    def test_authenticated_classification_saves_scan(self):
        """Authenticated scans should automatically save to history and return non-null scan_id."""
        image = _create_test_image()
        response = self.client.post(
            "/api/v1/classify/",
            {"image": image},
            HTTP_AUTHORIZATION=self.auth_header,
            format="multipart"
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data.get("saved"), True)
        self.assertIsNotNone(response.data.get("scan_id"))
        self.assertEqual(ClassificationHistory.objects.count(), 1)
        scan = ClassificationHistory.objects.first()
        self.assertEqual(scan.user, self.user)

    def test_list_history_returns_only_own_records(self):
        """Users can only view their own scan histories."""
        image1 = _create_test_image()
        image2 = _create_test_image()

        ClassificationHistory.objects.create(
            user=self.user,
            image=image1,
            label="Fresh",
            confidence=0.98
        )
        ClassificationHistory.objects.create(
            user=self.other_user,
            image=image2,
            label="Not Fresh",
            confidence=0.88
        )

        response = self.client.get(
            "/api/v1/history/",
            HTTP_AUTHORIZATION=self.auth_header
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data.get("count"), 1)
        self.assertEqual(len(response.data.get("history")), 1)
        self.assertEqual(response.data.get("history")[0]["label"], "Fresh")

    def test_history_detail_and_delete_permissions(self):
        """User can retrieve and delete their own scan, but cannot access others' scans."""
        image1 = _create_test_image()
        image2 = _create_test_image()

        own_scan = ClassificationHistory.objects.create(
            user=self.user,
            image=image1,
            label="Fresh",
            confidence=0.95
        )
        other_scan = ClassificationHistory.objects.create(
            user=self.other_user,
            image=image2,
            label="Not Fresh",
            confidence=0.91
        )

        # Retrieve own scan: 200 OK
        resp = self.client.get(
            f"/api/v1/history/{own_scan.scan_id}/",
            HTTP_AUTHORIZATION=self.auth_header
        )
        self.assertEqual(resp.status_code, status.HTTP_200_OK)
        self.assertEqual(resp.data.get("scan_id"), own_scan.scan_id)

        # Retrieve other's scan: 404 NOT FOUND
        resp = self.client.get(
            f"/api/v1/history/{other_scan.scan_id}/",
            HTTP_AUTHORIZATION=self.auth_header
        )
        self.assertEqual(resp.status_code, status.HTTP_404_NOT_FOUND)

        # Delete own scan: 204 NO CONTENT
        resp = self.client.delete(
            f"/api/v1/history/{own_scan.scan_id}/",
            HTTP_AUTHORIZATION=self.auth_header
        )
        self.assertEqual(resp.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(ClassificationHistory.objects.filter(scan_id=own_scan.scan_id).exists())

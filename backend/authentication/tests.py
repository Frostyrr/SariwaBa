from unittest.mock import patch
from django.contrib.auth.models import User
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase

from .models import UserProfile


class GoogleAuthTests(APITestCase):

    def setUp(self):
        self.auth_url = reverse("google-auth")
        self.profile_url = reverse("profile")
        self.logout_url = reverse("logout")
        self.refresh_url = reverse("token-refresh")

    def test_missing_token_returns_400(self):
        response = self.client.post(self.auth_url, {}, format="json")
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data["error"]["code"], "MISSING_TOKEN")

    @patch("authentication.views.verify_google_token")
    def test_invalid_token_returns_401(self, mock_verify):
        mock_verify.return_value = None
        response = self.client.post(self.auth_url, {"id_token": "invalid"}, format="json")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data["error"]["code"], "INVALID_TOKEN")

    @patch("authentication.views.verify_google_token")
    def test_unverified_email_returns_401(self, mock_verify):
        mock_verify.return_value = {
            "google_id": "12345",
            "email": "user@example.com",
            "name": "Test User",
            "picture": "https://example.com/pic.jpg",
            "email_verified": False,
        }
        response = self.client.post(self.auth_url, {"id_token": "unverified"}, format="json")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data["error"]["code"], "EMAIL_NOT_VERIFIED")

    @patch("authentication.views.verify_google_token")
    def test_successful_auth_creates_user_and_returns_tokens(self, mock_verify):
        mock_verify.return_value = {
            "google_id": "google_sub_123",
            "email": "freshfish@example.com",
            "name": "Fresh Fisherman",
            "picture": "https://example.com/avatar.jpg",
            "email_verified": True,
        }
        response = self.client.post(self.auth_url, {"id_token": "valid_token"}, format="json")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data["created"])
        self.assertIn("access", response.data)
        self.assertIn("refresh", response.data)
        self.assertEqual(response.data["user"]["email"], "freshfish@example.com")
        self.assertEqual(response.data["user"]["first_name"], "Fresh")
        self.assertEqual(response.data["user"]["last_name"], "Fisherman")

        # Verify profile created
        profile = UserProfile.objects.get(google_id="google_sub_123")
        self.assertEqual(profile.user.email, "freshfish@example.com")

        # Verify access token works with /profile/
        access_token = response.data["access"]
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {access_token}")
        profile_res = self.client.get(self.profile_url)
        self.assertEqual(profile_res.status_code, status.HTTP_200_OK)
        self.assertEqual(profile_res.data["user"]["email"], "freshfish@example.com")

        # Test token refresh works
        refresh_token = response.data["refresh"]
        refresh_res = self.client.post(self.refresh_url, {"refresh": refresh_token}, format="json")
        self.assertEqual(refresh_res.status_code, status.HTTP_200_OK)
        self.assertIn("access", refresh_res.data)
        # Because ROTATE_REFRESH_TOKENS=True and BLACKLIST_AFTER_ROTATION=True,
        # the old refresh token is now blacklisted, and a new refresh token is issued.
        new_refresh_token = refresh_res.data.get("refresh", refresh_token)

        # Old refresh token is already blacklisted
        old_refresh_fail = self.client.post(self.refresh_url, {"refresh": refresh_token}, format="json")
        self.assertEqual(old_refresh_fail.status_code, status.HTTP_401_UNAUTHORIZED)

        # Test logout blacklists the new refresh token
        logout_res = self.client.post(self.logout_url, {"refresh": new_refresh_token}, format="json")
        self.assertEqual(logout_res.status_code, status.HTTP_204_NO_CONTENT)

        # Refreshing new token should now also fail
        new_refresh_fail = self.client.post(self.refresh_url, {"refresh": new_refresh_token}, format="json")
        self.assertEqual(new_refresh_fail.status_code, status.HTTP_401_UNAUTHORIZED)


from unittest.mock import patch
from django.contrib.auth.models import User
from django.core.exceptions import PermissionDenied
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from rest_framework_simplejwt.tokens import RefreshToken

from classification.models import ClassificationHistory, ClassificationTelemetryLog
from .models import LoginAuditLog, UserProfile


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

        # Verify audit log created
        log = LoginAuditLog.objects.first()
        self.assertIsNotNone(log)
        self.assertEqual(log.status, "FAILED_MISSING_TOKEN")

    @patch("authentication.views.verify_google_token")
    def test_invalid_token_returns_401(self, mock_verify):
        mock_verify.return_value = None
        response = self.client.post(self.auth_url, {"id_token": "invalid"}, format="json")
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(response.data["error"]["code"], "INVALID_TOKEN")

        log = LoginAuditLog.objects.first()
        self.assertEqual(log.status, "FAILED_INVALID_TOKEN")

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

        log = LoginAuditLog.objects.first()
        self.assertEqual(log.status, "FAILED_EMAIL_UNVERIFIED")
        self.assertEqual(log.email, "user@example.com")

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
        self.assertFalse(response.data["user"]["is_suspended"])

        # Verify profile created
        profile = UserProfile.objects.get(google_id="google_sub_123")
        self.assertEqual(profile.user.email, "freshfish@example.com")

        # Verify login audit log
        log = LoginAuditLog.objects.filter(status="SUCCESS").first()
        self.assertIsNotNone(log)
        self.assertEqual(log.email, "freshfish@example.com")

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

    @patch("authentication.views.verify_google_token")
    def test_suspended_user_is_blocked_from_login(self, mock_verify):
        user = User.objects.create_user(username="suspended@example.com", email="suspended@example.com")
        UserProfile.objects.create(user=user, google_id="gid_suspended", role="user", is_suspended=True)

        mock_verify.return_value = {
            "google_id": "gid_suspended",
            "email": "suspended@example.com",
            "name": "Suspended Person",
            "picture": "",
            "email_verified": True,
        }

        response = self.client.post(self.auth_url, {"id_token": "valid_but_suspended"}, format="json")
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(response.data["error"]["code"], "ACCOUNT_SUSPENDED")

        # Check audit log
        log = LoginAuditLog.objects.filter(email="suspended@example.com", status="SUSPENDED_BLOCKED").first()
        self.assertIsNotNone(log)


class AdminRBACTests(APITestCase):

    def setUp(self):
        # Create normal user
        self.user = User.objects.create_user(username="user@example.com", email="user@example.com", first_name="Normal", last_name="User")
        self.user_profile = UserProfile.objects.create(user=self.user, google_id="gid_user", role="user")
        self.user_token = str(RefreshToken.for_user(self.user).access_token)

        # Create admin user
        self.admin = User.objects.create_user(username="admin@example.com", email="admin@example.com", first_name="Lead", last_name="Admin")
        self.admin_profile = UserProfile.objects.create(user=self.admin, google_id="gid_admin", role="admin")
        self.admin_token = str(RefreshToken.for_user(self.admin).access_token)

        self.stats_url = reverse("admin-stats")
        self.users_url = reverse("admin-users")
        self.security_url = reverse("admin-security")
        self.health_url = reverse("admin-health")
        self.audits_url = reverse("admin-audits")

    def test_anonymous_access_to_admin_is_unauthorized(self):
        res = self.client.get(self.stats_url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_non_admin_access_to_admin_is_forbidden(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.user_token}")
        res = self.client.get(self.stats_url)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

        res_users = self.client.get(self.users_url)
        self.assertEqual(res_users.status_code, status.HTTP_403_FORBIDDEN)

    def test_admin_can_access_all_monitoring_endpoints(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.admin_token}")

        # Stats
        res_stats = self.client.get(self.stats_url)
        self.assertEqual(res_stats.status_code, status.HTTP_200_OK)
        self.assertIn("totals", res_stats.data)
        self.assertIn("distribution", res_stats.data)
        self.assertIn("confidence", res_stats.data)
        self.assertIn("rejection_metrics", res_stats.data)
        self.assertIn("latency_metrics", res_stats.data)

        # Users
        res_users = self.client.get(self.users_url)
        self.assertEqual(res_users.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(res_users.data["count"], 2)

        # Security
        res_sec = self.client.get(self.security_url)
        self.assertEqual(res_sec.status_code, status.HTTP_200_OK)
        self.assertIn("metrics", res_sec.data)
        self.assertIn("recent_logs", res_sec.data)

        # Health
        res_health = self.client.get(self.health_url)
        self.assertEqual(res_health.status_code, status.HTTP_200_OK)
        self.assertEqual(res_health.data["database"]["status"], "HEALTHY")
        self.assertEqual(res_health.data["ml_model"]["architecture"], "MobileNetV3-Small")

        # Audits
        res_audits = self.client.get(self.audits_url)
        self.assertEqual(res_audits.status_code, status.HTTP_200_OK)
        self.assertIn("results", res_audits.data)

    def test_admin_can_update_user_role(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.admin_token}")
        url = reverse("admin-user-role", kwargs={"user_id": self.user.id})

        res = self.client.patch(url, {"role": "admin"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.user_profile.refresh_from_db()
        self.assertEqual(self.user_profile.role, "admin")

    def test_admin_cannot_demote_self(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.admin_token}")
        url = reverse("admin-user-role", kwargs={"user_id": self.admin.id})

        res = self.client.patch(url, {"role": "user"}, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data["error"]["code"], "SELF_DEMOTION_PROHIBITED")

    def test_admin_can_suspend_and_reactivate_user(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.admin_token}")
        url = reverse("admin-user-suspend", kwargs={"user_id": self.user.id})

        # Suspend
        res_suspend = self.client.post(url, {"is_suspended": True}, format="json")
        self.assertEqual(res_suspend.status_code, status.HTTP_200_OK)
        self.user_profile.refresh_from_db()
        self.assertTrue(self.user_profile.is_suspended)
        self.assertIsNotNone(self.user_profile.suspended_at)

        # Reactivate
        res_reactivate = self.client.post(url, {"is_suspended": False}, format="json")
        self.assertEqual(res_reactivate.status_code, status.HTTP_200_OK)
        self.user_profile.refresh_from_db()
        self.assertFalse(self.user_profile.is_suspended)

    def test_admin_cannot_suspend_self(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.admin_token}")
        url = reverse("admin-user-suspend", kwargs={"user_id": self.admin.id})

        res = self.client.post(url, {"is_suspended": True}, format="json")
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data["error"]["code"], "SELF_SUSPENSION_PROHIBITED")

    def test_audit_logs_are_append_only_and_cannot_be_deleted(self):
        log = LoginAuditLog.objects.create(
            email="test@audit.com",
            ip_address="127.0.0.1",
            status="SUCCESS",
        )
        with self.assertRaises(PermissionDenied):
            log.delete()

        telemetry = ClassificationTelemetryLog.objects.create(
            user=self.user,
            status="SUCCESS",
            latency_ms=45.2,
        )
        with self.assertRaises(PermissionDenied):
            telemetry.delete()

    def test_delete_account_anonymous_is_unauthorized(self):
        url = reverse("delete-account")
        res = self.client.delete(url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_delete_account_last_admin_is_prohibited(self):
        # self.admin is the only admin
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.admin_token}")
        url = reverse("delete-account")
        res = self.client.delete(url)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(res.data["error"]["code"], "LAST_ADMIN_DELETION_PROHIBITED")

    def test_delete_account_normal_user_succeeds(self):
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {self.user_token}")
        url = reverse("delete-account")
        res = self.client.delete(url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertFalse(User.objects.filter(id=self.user.id).exists())


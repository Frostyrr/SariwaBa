from django.core.exceptions import PermissionDenied
from django.db import models
from django.contrib.auth.models import User


class UserProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="profile"
    )

    google_id = models.CharField(
        max_length=255,
        unique=True,
    )

    profile_picture = models.URLField(
        blank=True,
        null=True,
    )

    ROLE_CHOICES = [
        ("user", "User"),
        ("admin", "Admin"),
    ]

    role = models.CharField(
        max_length=20,
        choices=ROLE_CHOICES,
        default="user",
    )

    is_suspended = models.BooleanField(
        default=False,
    )

    suspended_at = models.DateTimeField(
        null=True,
        blank=True,
    )

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    updated_at = models.DateTimeField(
        auto_now=True
    )

    @property
    def is_admin(self):
        return self.role == "admin" or self.user.is_staff or self.user.is_superuser

    def __str__(self):
        return self.user.email


class LoginAuditLog(models.Model):
    STATUS_CHOICES = [
        ("SUCCESS", "Success"),
        ("FAILED_INVALID_TOKEN", "Failed - Invalid Token"),
        ("FAILED_EMAIL_UNVERIFIED", "Failed - Email Unverified"),
        ("FAILED_MISSING_TOKEN", "Failed - Missing Token"),
        ("SUSPENDED_BLOCKED", "Blocked - Account Suspended"),
        ("ERROR", "Error"),
    ]

    email = models.CharField(max_length=255, blank=True, default="")
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True, default="")
    status = models.CharField(max_length=50, choices=STATUS_CHOICES)
    failure_reason = models.CharField(max_length=255, blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "login_audit_logs"
        ordering = ["-created_at"]

    def delete(self, *args, **kwargs):
        raise PermissionDenied("Audit logs are strictly append-only and cannot be deleted.")

    def __str__(self):
        return f"{self.email} - {self.status} - {self.created_at}"

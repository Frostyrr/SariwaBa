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

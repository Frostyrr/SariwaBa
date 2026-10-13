from django.db import models
from django.contrib.auth.models import User


# Create your models here.

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

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    updated_at = models.DateTimeField(
        auto_now=True
    )

    def __str__(self):
        return self.user.email



class ClassificationHistory(models.Model):

    LABEL_CHOICES = [
        ("Fresh", "Fresh"),
        ("Not Fresh", "Not Fresh"),
    ]

    scan_id = models.BigAutoField(
        primary_key=True
    )

    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="classification_history"
    )

    image = models.ImageField(
        upload_to="fish_scans/"
    )

    label = models.CharField(
        max_length=20,
        choices=LABEL_CHOICES
    )

    confidence = models.FloatField()

    created_at = models.DateTimeField(
        auto_now_add=True
    )

    class Meta:
        db_table = "classification_history"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.scan_id} - {self.label}"



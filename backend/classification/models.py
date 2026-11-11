from django.core.exceptions import PermissionDenied
from django.db import models
from django.contrib.auth.models import User


class ClassificationHistory(models.Model):
    LABEL_CHOICES = [
        ("Fresh", "Fresh"),
        ("Not Fresh", "Not Fresh"),
    ]

    REGION_CHOICES = [
        ("eye", "Eye"),
        ("gill", "Gill"),
    ]

    scan_id = models.BigAutoField(primary_key=True)
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="classification_history"
    )
    image = models.ImageField(upload_to="fish_scans/")
    region_type = models.CharField(
        max_length=10,
        choices=REGION_CHOICES,
        default="eye",
    )
    label = models.CharField(max_length=20, choices=LABEL_CHOICES)
    confidence = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "classification_history"
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.scan_id} - {self.region_type} - {self.label}"


class ClassificationTelemetryLog(models.Model):
    STATUS_CHOICES = [
        ("SUCCESS", "Success"),
        ("REJECTED_UNSUPPORTED_TYPE", "Rejected - Unsupported Type"),
        ("REJECTED_DIMENSIONS", "Rejected - Invalid Dimensions"),
        ("REJECTED_SIZE", "Rejected - Image Too Large"),
        ("REJECTED_CORRUPTED", "Rejected - Corrupted Image"),
        ("REJECTED_EMPTY", "Rejected - Empty Image"),
        ("REJECTED_INVALID_REGION", "Rejected - Invalid Region"),
        ("ERROR_INFERENCE", "Error - Inference Failed"),
        ("ERROR_MODEL_UNAVAILABLE", "Error - Model Unavailable"),
    ]

    user = models.ForeignKey(
        User,
        null=True,
        blank=True,
        on_delete=models.SET_NULL,
        related_name="classification_telemetry_logs",
    )
    region_type = models.CharField(max_length=20, blank=True, default="")
    status = models.CharField(max_length=50, choices=STATUS_CHOICES)
    label = models.CharField(max_length=20, blank=True, null=True)
    confidence = models.FloatField(blank=True, null=True)
    latency_ms = models.FloatField(blank=True, null=True)
    error_code = models.CharField(max_length=100, blank=True, default="")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = "classification_telemetry_logs"
        ordering = ["-created_at"]

    def delete(self, *args, **kwargs):
        raise PermissionDenied("Telemetry logs are strictly append-only and cannot be deleted.")

    def __str__(self):
        return f"{self.status} - {self.region_type} - {self.latency_ms}ms - {self.created_at}"

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

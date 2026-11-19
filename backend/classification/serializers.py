from rest_framework import serializers
from .models import ClassificationHistory


class ClassificationHistorySerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()
    classification = serializers.CharField(source="label", read_only=True)
    region_verified = serializers.SerializerMethodField()
    species_verified = serializers.SerializerMethodField()
    validator_version = serializers.SerializerMethodField()
    assessment_species = serializers.SerializerMethodField()

    class Meta:
        model = ClassificationHistory
        fields = [
            "scan_id",
            "classification",
            "label",
            "confidence",
            "region_type",
            "image",
            "image_url",
            "created_at",
            "validation",
            "region_verified",
            "species_verified",
            "validator_version",
            "assessment_species",
        ]
        read_only_fields = fields

    def get_region_verified(self, obj):
        return obj.validation.get("region_verified", False)

    def get_species_verified(self, obj):
        return obj.validation.get("species_verified", False)

    def get_validator_version(self, obj):
        return obj.validation.get("validator_version")

    def get_assessment_species(self, obj):
        return "Tilapia"

    def get_image_url(self, obj):
        request = self.context.get("request")
        if obj.image and hasattr(obj.image, "url"):
            if request is not None:
                return request.build_absolute_uri(obj.image.url)
            return obj.image.url
        return None

from rest_framework import serializers
from .models import ClassificationHistory


class ClassificationHistorySerializer(serializers.ModelSerializer):
    image_url = serializers.SerializerMethodField()

    class Meta:
        model = ClassificationHistory
        fields = [
            "scan_id",
            "label",
            "confidence",
            "image",
            "image_url",
            "created_at",
        ]
        read_only_fields = fields

    def get_image_url(self, obj):
        request = self.context.get("request")
        if obj.image and hasattr(obj.image, "url"):
            if request is not None:
                return request.build_absolute_uri(obj.image.url)
            return obj.image.url
        return None

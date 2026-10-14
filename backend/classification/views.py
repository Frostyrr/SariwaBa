from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import (
    api_view,
    permission_classes,
    parser_classes,
)
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import AllowAny
from PIL import Image, UnidentifiedImageError

from .models import ClassificationHistory

@api_view(["POST"])
@permission_classes([AllowAny])
@parser_classes([MultiPartParser, FormParser])
def classify_fish(request):
    image_file = request.FILES.get("image")

    if image_file is None:
        return Response(
            {
                "error": {
                    "code": "MISSING_IMAGE",
                    "message": "Fish image is required."
                }
            },
            status=status.HTTP_400_BAD_REQUEST
        )

    max_size = 5 * 1024 * 1024  # 5MB
    if image_file.size > max_size:
        return Response(
            {
                "error": {
                    "code": "IMAGE_TOO_LARGE",
                    "message": "Image must not exceed 5 MB."
                }
            },
            status=status.HTTP_400_BAD_REQUEST
        )

    allowed_content_types = ["image/jpeg", "image/png"]
    if image_file.content_type not in allowed_content_types:
        return Response(
            {
                "error": {
                    "code": "UNSUPPORTED_IMAGE_TYPE",
                    "message": "Only JPEG and PNG images are allowed."
                }
            },
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        image = Image.open(image_file)
        image.verify()
        image_file.seek(0)
    except (UnidentifiedImageError, OSError):
        return Response(
            {
                "error": {
                    "code": "INVALID_IMAGE",
                    "message": "The uploaded file could not be decoded as an image."
                }
            },
            status=status.HTTP_400_BAD_REQUEST
        )

    # Temporary result before MobileNetV3 model integration
    label = "Fresh"
    confidence = 0.95
    scan_id = None

    if request.user.is_authenticated:
        classification = ClassificationHistory.objects.create(
            user=request.user,
            image=image_file,
            label=label,
            confidence=confidence
        )
        scan_id = classification.scan_id

    return Response(
        {
            "label": label,
            "confidence": confidence,
            "scan_id": scan_id,
            "saved": request.user.is_authenticated,
        },
        status=status.HTTP_200_OK
    )

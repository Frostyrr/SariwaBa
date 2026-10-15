from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import (
    api_view,
    permission_classes,
    parser_classes,
)
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import AllowAny, IsAuthenticated
from PIL import Image, UnidentifiedImageError

from .models import ClassificationHistory
from .serializers import ClassificationHistorySerializer

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


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def list_history(request):
    """
    Retrieve classification history records belonging to the authenticated user.
    """
    history = ClassificationHistory.objects.filter(user=request.user)
    serializer = ClassificationHistorySerializer(
        history,
        many=True,
        context={"request": request}
    )
    return Response(
        {
            "count": history.count(),
            "history": serializer.data,
        },
        status=status.HTTP_200_OK
    )


@api_view(["GET", "DELETE"])
@permission_classes([IsAuthenticated])
def history_detail(request, scan_id):
    """
    Retrieve or delete an individual classification history record owned by the authenticated user.
    """
    record = ClassificationHistory.objects.filter(
        scan_id=scan_id,
        user=request.user
    ).first()

    if record is None:
        return Response(
            {
                "error": {
                    "code": "SCAN_NOT_FOUND",
                    "message": "Classification scan record not found or access denied."
                }
            },
            status=status.HTTP_404_NOT_FOUND
        )

    if request.method == "GET":
        serializer = ClassificationHistorySerializer(
            record,
            context={"request": request}
        )
        return Response(serializer.data, status=status.HTTP_200_OK)

    if request.method == "DELETE":
        # Delete image from storage if present
        if record.image:
            try:
                record.image.delete(save=False)
            except Exception:
                pass
        record.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)


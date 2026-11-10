from PIL import Image, UnidentifiedImageError
try:
    from pillow_heif import register_heif_opener
    register_heif_opener()
except ImportError:
    pass
from rest_framework import status
from rest_framework.decorators import (
    api_view,
    parser_classes,
    permission_classes,
)
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from ml.predict import (
    ModelInferenceError,
    ModelUnavailableError,
    predict_image,
)

from .models import ClassificationHistory
from .serializers import ClassificationHistorySerializer


MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024  # 5 MB
MIN_IMAGE_DIMENSION = 32
MAX_IMAGE_DIMENSION = 4096
MAX_IMAGE_PIXELS = 16_777_216  # 4096 x 4096

ALLOWED_CONTENT_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/heic",
    "image/heif",
    "image/heic-sequence",
    "image/heif-sequence",
    "application/octet-stream",
    "",
}
ALLOWED_DECODED_FORMATS = {"JPEG", "PNG", "HEIF", "HEIC"}
ALLOWED_REGION_TYPES = {"eye", "gill"}

PRELIMINARY_DISCLAIMER = (
    "This is a preliminary visual freshness assessment and does not guarantee food safety."
)


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
                    "message": "Fish image is required.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    raw_region = request.data.get("region_type")
    region_type = (
        str(raw_region).strip().lower() if raw_region is not None else ""
    )
    if region_type not in ALLOWED_REGION_TYPES:
        return Response(
            {
                "error": {
                    "code": "INVALID_REGION_TYPE",
                    "message": "A valid anatomical region_type ('eye' or 'gill') is required.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    if image_file.size <= 0:
        return Response(
            {
                "error": {
                    "code": "EMPTY_IMAGE",
                    "message": "The uploaded image file is empty.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    if image_file.size > MAX_FILE_SIZE_BYTES:
        return Response(
            {
                "error": {
                    "code": "IMAGE_TOO_LARGE",
                    "message": "Image must not exceed 5 MB.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    content_type = (image_file.content_type or "").lower().strip()
    if content_type not in ALLOWED_CONTENT_TYPES:
        return Response(
            {
                "error": {
                    "code": "UNSUPPORTED_IMAGE_TYPE",
                    "message": "Only JPEG, PNG, and HEIC images are allowed.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        image_file.seek(0)
        with Image.open(image_file) as img:
            decoded_format = (img.format or "").upper()
            width, height = img.size
            img.verify()

        if decoded_format not in ALLOWED_DECODED_FORMATS:
            return Response(
                {
                    "error": {
                        "code": "UNSUPPORTED_IMAGE_TYPE",
                        "message": "Decoded image format is not supported. Only JPEG, PNG, and HEIC images are allowed.",
                    }
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        if (
            width < MIN_IMAGE_DIMENSION
            or height < MIN_IMAGE_DIMENSION
            or width > MAX_IMAGE_DIMENSION
            or height > MAX_IMAGE_DIMENSION
            or (width * height) > MAX_IMAGE_PIXELS
        ):
            return Response(
                {
                    "error": {
                        "code": "INVALID_IMAGE_DIMENSIONS",
                        "message": (
                            f"Image dimensions ({width}x{height}) are outside the allowed range "
                            f"({MIN_IMAGE_DIMENSION}x{MIN_IMAGE_DIMENSION} to {MAX_IMAGE_DIMENSION}x{MAX_IMAGE_DIMENSION} px)."
                        ),
                    }
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Second pass: fully decode pixel data to catch truncated or corrupted streams
        image_file.seek(0)
        with Image.open(image_file) as img_check:
            img_check.load()

        image_file.seek(0)
    except Image.DecompressionBombError:
        return Response(
            {
                "error": {
                    "code": "INVALID_IMAGE_DIMENSIONS",
                    "message": "Image resolution exceeds safe processing limits.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )
    except (UnidentifiedImageError, OSError, SyntaxError, ValueError):
        return Response(
            {
                "error": {
                    "code": "INVALID_IMAGE",
                    "message": "The uploaded file could not be decoded as a valid image.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        image_file.seek(0)
        prediction = predict_image(image_file, region_type=region_type)
    except ModelUnavailableError as exc:
        return Response(
            {
                "error": {
                    "code": "MODEL_UNAVAILABLE",
                    "message": str(exc),
                }
            },
            status=status.HTTP_503_SERVICE_UNAVAILABLE,
        )
    except (ModelInferenceError, Exception):
        return Response(
            {
                "error": {
                    "code": "INFERENCE_FAILED",
                    "message": "Unable to complete freshness classification for this image.",
                }
            },
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )

    label = prediction["label"]
    confidence = prediction["confidence"]

    image_file.seek(0)
    scan_id = None

    if request.user.is_authenticated:
        classification = ClassificationHistory.objects.create(
            user=request.user,
            image=image_file,
            region_type=region_type,
            label=label,
            confidence=confidence,
        )
        scan_id = classification.scan_id

    return Response(
        {
            "classification": label,
            "label": label,
            "confidence": confidence,
            "region_type": region_type,
            "species": "Tilapia",
            "disclaimer": PRELIMINARY_DISCLAIMER,
            "scan_id": scan_id,
            "saved": request.user.is_authenticated,
        },
        status=status.HTTP_200_OK,
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
        context={"request": request},
    )
    return Response(
        {
            "count": history.count(),
            "history": serializer.data,
        },
        status=status.HTTP_200_OK,
    )


@api_view(["GET", "DELETE"])
@permission_classes([IsAuthenticated])
def history_detail(request, scan_id):
    """
    Retrieve or delete an individual classification history record owned by the authenticated user.
    """
    record = ClassificationHistory.objects.filter(
        scan_id=scan_id,
        user=request.user,
    ).first()

    if record is None:
        return Response(
            {
                "error": {
                    "code": "SCAN_NOT_FOUND",
                    "message": "Classification scan record not found or access denied.",
                }
            },
            status=status.HTTP_404_NOT_FOUND,
        )

    if request.method == "GET":
        serializer = ClassificationHistorySerializer(
            record,
            context={"request": request},
        )
        return Response(serializer.data, status=status.HTTP_200_OK)

    if request.method == "DELETE":
        if record.image:
            try:
                record.image.delete(save=False)
            except Exception:
                pass
        record.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

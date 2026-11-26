import base64
import io
import logging
import time
import math
from django.conf import settings
from PIL import Image, ImageOps, UnidentifiedImageError
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
from ml.eye_proposals import DetectorUnavailable, propose_eye_crops
from ml.validator import EXPERIMENTAL_NOTICE, InputRejectedError, validate_image

from .models import ClassificationHistory, ClassificationTelemetryLog
from .serializers import ClassificationHistorySerializer


MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024  # 5 MB
MAX_EYE_SOURCE_BYTES = 10 * 1024 * 1024
MIN_IMAGE_DIMENSION = 32
MAX_IMAGE_DIMENSION = 4096
MAX_IMAGE_PIXELS = 16_777_216  # 4096 x 4096
MAX_EYE_SOURCE_DIMENSION = 8192
MAX_EYE_SOURCE_PIXELS = 50_331_648  # Up to ~50 MP smartphone camera whole-fish photos

ALLOWED_CONTENT_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp",
    "image/heic",
    "image/heif",
    "image/heic-sequence",
    "image/heif-sequence",
    "application/octet-stream",
    "",
}
ALLOWED_DECODED_FORMATS = {"JPEG", "PNG", "WEBP", "HEIF", "HEIC"}
ALLOWED_REGION_TYPES = {"auto", "eye", "gill"}

PRELIMINARY_DISCLAIMER = (
    "This is a preliminary visual freshness assessment and does not guarantee food safety."
)


@api_view(["POST"])
@permission_classes([AllowAny])
@parser_classes([MultiPartParser, FormParser])
def eye_proposals(request):
    upload = request.FILES.get("image")
    if upload is None or upload.size <= 0:
        return Response(
            {"error": {"code": "EMPTY_IMAGE", "message": "A valid Tilapia photo is required."}},
            status=status.HTTP_400_BAD_REQUEST,
        )
    if upload.size > MAX_EYE_SOURCE_BYTES:
        return Response(
            {"error": {"code": "IMAGE_TOO_LARGE", "message": "The original photo must be 10 MB or smaller."}},
            status=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
        )

    try:
        with Image.open(upload) as source:
            decoded_format = (source.format or "").upper()
            width, height = source.size
            if (decoded_format not in ALLOWED_DECODED_FORMATS
                    or not all(MIN_IMAGE_DIMENSION <= size <= MAX_EYE_SOURCE_DIMENSION
                               for size in source.size)
                    or width * height > MAX_EYE_SOURCE_PIXELS):
                return Response(
                    {
                        "error": {
                            "code": "INVALID_IMAGE_DIMENSIONS",
                            "message": "Photo format or dimensions are outside supported limits.",
                        }
                    },
                    status=status.HTTP_400_BAD_REQUEST,
                )
            image = ImageOps.exif_transpose(source).convert("RGB")
            if image.width > MAX_IMAGE_DIMENSION or image.height > MAX_IMAGE_DIMENSION:
                image.thumbnail((MAX_IMAGE_DIMENSION, MAX_IMAGE_DIMENSION), Image.Resampling.LANCZOS)
    except (ValueError, OSError, Image.DecompressionBombError):
        return Response(
            {"error": {"code": "INVALID_IMAGE", "message": "The uploaded file could not be decoded as a valid image."}},
            status=status.HTTP_400_BAD_REQUEST,
        )

    is_heic = decoded_format in {"HEIC", "HEIF"}
    size_meta = {"image_width": image.width, "image_height": image.height}

    original_rejection = None
    try:
        validate_image(image, "eye")
    except InputRejectedError as exc:
        if exc.code in {"UNSUPPORTED_IMAGE", "CONTENT_UNCERTAIN"}:
            original_rejection = exc
        elif exc.code != "WHOLE_TILAPIA_CLOSE_UP_REQUIRED":
            return Response(
                {"error": {"code": exc.code, "message": str(exc)}},
                status=status.HTTP_422_UNPROCESSABLE_ENTITY,
            )
    except (ModelUnavailableError, ModelInferenceError):
        return Response(
            {"error": {"code": "MODEL_UNAVAILABLE", "message": "Eye validation model is currently unavailable."}},
            status=status.HTTP_503_SERVICE_UNAVAILABLE,
        )
    else:
        payload = {"already_eye": True, "proposals": []}
        if is_heic:
            payload.update(size_meta)
        return Response(payload)

    proposals = []
    try:
        for (left, top, right, bottom), eye_center in propose_eye_crops(image):
            crop = image.crop((left, top, right, bottom))
            crop.thumbnail((1024, 1024), Image.Resampling.LANCZOS)
            # Enforce Model A supported-input gate on every proposed YOLO crop,
            # including whole-Tilapia uploads, so stray reflections/glare never bypass validation.
            try:
                validate_image(crop, "eye")
            except InputRejectedError:
                continue
            with io.BytesIO() as output:
                crop.save(output, format="JPEG", quality=95)
                crop_bytes = output.getvalue()
            proposals.append({
                "crop_base64": base64.b64encode(crop_bytes).decode("ascii"),
                "rect": [left / image.width, top / image.height,
                         right / image.width, bottom / image.height],
                "eye_center": eye_center,
            })
    except DetectorUnavailable as exc:
        if exc.__cause__ is not None:
            logging.getLogger(__name__).exception("Eye detector failed.")
        return Response(
            {"error": {"code": "MODEL_UNAVAILABLE", "message": "Automatic eye detection is currently unavailable."}},
            status=status.HTTP_503_SERVICE_UNAVAILABLE,
        )
    except (ModelUnavailableError, ModelInferenceError):
        return Response(
            {"error": {"code": "MODEL_UNAVAILABLE", "message": "Eye validation model is currently unavailable."}},
            status=status.HTTP_503_SERVICE_UNAVAILABLE,
        )
    if original_rejection is not None and not proposals:
        return Response(
            {"error": {"code": original_rejection.code, "message": str(original_rejection)}},
            status=status.HTTP_422_UNPROCESSABLE_ENTITY,
        )
    payload = {"proposals": proposals}
    if proposals or is_heic:
        payload.update(size_meta)
    return Response(payload)


@api_view(["POST"])
@permission_classes([AllowAny])
@parser_classes([MultiPartParser, FormParser])
def classify_fish(request):
    image_file = request.FILES.get("image")
    user = request.user if request.user.is_authenticated else None

    if image_file is None:
        ClassificationTelemetryLog.objects.create(
            user=user,
            status="REJECTED_EMPTY",
            error_code="MISSING_IMAGE",
        )
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
        ClassificationTelemetryLog.objects.create(
            user=user,
            region_type=region_type[:20],
            status="REJECTED_INVALID_REGION",
            error_code="INVALID_REGION_TYPE",
        )
        return Response(
            {
                "error": {
                    "code": "INVALID_REGION_TYPE",
                    "message": "A valid anatomical region_type ('auto', 'eye' or 'gill') is required.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    if image_file.size <= 0:
        ClassificationTelemetryLog.objects.create(
            user=user,
            region_type=region_type,
            status="REJECTED_EMPTY",
            error_code="EMPTY_IMAGE",
        )
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
        ClassificationTelemetryLog.objects.create(
            user=user,
            region_type=region_type,
            status="REJECTED_SIZE",
            error_code="IMAGE_TOO_LARGE",
        )
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
        ClassificationTelemetryLog.objects.create(
            user=user,
            region_type=region_type,
            status="REJECTED_UNSUPPORTED_TYPE",
            error_code="UNSUPPORTED_IMAGE_TYPE",
        )
        return Response(
            {
                "error": {
                    "code": "UNSUPPORTED_IMAGE_TYPE",
                    "message": "Only JPEG, PNG, WebP, and HEIC images are allowed.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    try:
        image_file.seek(0)
        with Image.open(image_file) as img:
            decoded_format = (img.format or "").upper()
            width, height = img.size

            if decoded_format not in ALLOWED_DECODED_FORMATS:
                ClassificationTelemetryLog.objects.create(
                    user=user,
                    region_type=region_type,
                    status="REJECTED_UNSUPPORTED_TYPE",
                    error_code="UNSUPPORTED_IMAGE_TYPE",
                )
                return Response(
                    {
                        "error": {
                            "code": "UNSUPPORTED_IMAGE_TYPE",
                            "message": "Decoded image format is not supported. Only JPEG, PNG, WebP, and HEIC images are allowed.",
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
                ClassificationTelemetryLog.objects.create(
                    user=user,
                    region_type=region_type,
                    status="REJECTED_DIMENSIONS",
                    error_code="INVALID_IMAGE_DIMENSIONS",
                )
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

            # Single-pass full pixel decode catches truncated/corrupted streams without reopening
            img.load()

        image_file.seek(0)
    except Image.DecompressionBombError:
        ClassificationTelemetryLog.objects.create(
            user=user,
            region_type=region_type,
            status="REJECTED_DIMENSIONS",
            error_code="INVALID_IMAGE_DIMENSIONS",
        )
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
        ClassificationTelemetryLog.objects.create(
            user=user,
            region_type=region_type,
            status="REJECTED_CORRUPTED",
            error_code="INVALID_IMAGE",
        )
        return Response(
            {
                "error": {
                    "code": "INVALID_IMAGE",
                    "message": "The uploaded file could not be decoded as a valid image.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    start_time = time.perf_counter()
    try:
        image_file.seek(0)
        validation = validate_image(image_file, region_type)
        if region_type == "auto":
            detected_region = validation.get("region_type")
            if detected_region not in {"eye", "gill"}:
                raise ModelInferenceError("Validator did not resolve the anatomical region.")
            region_type = detected_region
        image_file.seek(0)
        prediction = predict_image(image_file, region_type=region_type)
        confidence = float(prediction["confidence"])
        if not math.isfinite(confidence) or not 0 <= confidence <= 1:
            raise ModelInferenceError("Invalid freshness confidence.")
        if prediction["label"] not in {"Fresh", "Not Fresh"}:
            raise ModelInferenceError("Invalid freshness label.")
        min_freshness_conf = float(getattr(settings, "FRESHNESS_MIN_CONFIDENCE", 0.55))
        if confidence < min_freshness_conf:
            raise InputRejectedError(
                "FRESHNESS_UNCERTAIN",
                "We couldn't get a clear freshness reading from this angle. Please try a brighter, closer photo.",
                confidence,
            )
        latency_ms = round((time.perf_counter() - start_time) * 1000, 2)
    except InputRejectedError as exc:
        latency_ms = round((time.perf_counter() - start_time) * 1000, 2)
        ClassificationTelemetryLog.objects.create(
            user=user, region_type=region_type, status="REJECTED_ASSESSMENT",
            latency_ms=latency_ms, error_code=exc.code, confidence=exc.confidence,
        )
        return Response({"error": {"code": exc.code, "message": str(exc)}},
                        status=status.HTTP_422_UNPROCESSABLE_ENTITY)
    except ModelUnavailableError as exc:
        latency_ms = round((time.perf_counter() - start_time) * 1000, 2)
        ClassificationTelemetryLog.objects.create(
            user=user,
            region_type=region_type,
            status="ERROR_MODEL_UNAVAILABLE",
            latency_ms=latency_ms,
            error_code="MODEL_UNAVAILABLE",
        )
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
        latency_ms = round((time.perf_counter() - start_time) * 1000, 2)
        ClassificationTelemetryLog.objects.create(
            user=user,
            region_type=region_type,
            status="ERROR_INFERENCE",
            latency_ms=latency_ms,
            error_code="INFERENCE_FAILED",
        )
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

    # Record successful classification telemetry log
    ClassificationTelemetryLog.objects.create(
        user=user,
        region_type=region_type,
        status="SUCCESS",
        label=label,
        confidence=confidence,
        latency_ms=latency_ms,
    )

    image_file.seek(0)
    scan_id = None

    if request.user.is_authenticated:
        classification = ClassificationHistory.objects.create(
            user=request.user,
            image=image_file,
            region_type=region_type,
            label=label,
            confidence=confidence,
            validation=validation,
        )
        scan_id = classification.scan_id

    return Response(
        {
            "classification": label,
            "label": label,
            "confidence": confidence,
            "region_type": region_type,
            "assessment_species": "Tilapia",
            **validation,
            "disclaimer": (
                f"{EXPERIMENTAL_NOTICE} {PRELIMINARY_DISCLAIMER}"
                if validation.get("experimental_demo") else PRELIMINARY_DISCLAIMER
            ),
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

@api_view(["DELETE", "POST"])
@permission_classes([IsAuthenticated])
def bulk_delete_history(request):
    """
    Bulk delete classification history records owned by the authenticated user.
    Expects JSON body: {"scan_ids": [1, 2, 3]}
    Returns: {"deleted_count": N, "deleted_ids": [...]}
    """
    scan_ids = request.data.get("scan_ids")
    if scan_ids is None or not isinstance(scan_ids, list):
        return Response(
            {
                "error": {
                    "code": "INVALID_SCAN_IDS",
                    "message": "A list of 'scan_ids' is required.",
                }
            },
            status=status.HTTP_400_BAD_REQUEST,
        )

    if not scan_ids:
        return Response(
            {
                "deleted_count": 0,
                "deleted_ids": [],
            },
            status=status.HTTP_200_OK,
        )

    records = list(
        ClassificationHistory.objects.filter(
            scan_id__in=scan_ids,
            user=request.user,
        )
    )

    deleted_ids = []
    for record in records:
        if record.image:
            try:
                record.image.delete(save=False)
            except Exception:
                pass
        deleted_ids.append(record.scan_id)

    if deleted_ids:
        ClassificationHistory.objects.filter(scan_id__in=deleted_ids).delete()

    return Response(
        {
            "deleted_count": len(deleted_ids),
            "deleted_ids": deleted_ids,
        },
        status=status.HTTP_200_OK,
    )


@api_view(["DELETE", "POST"])
@permission_classes([IsAuthenticated])
def clear_all_history(request):
    """
    Deletes all classification history records owned by the authenticated user,
    cleaning up associated fish scan image files on disk.
    """
    records = list(ClassificationHistory.objects.filter(user=request.user))
    count = len(records)
    for record in records:
        if record.image:
            try:
                record.image.delete(save=False)
            except Exception:
                pass
    ClassificationHistory.objects.filter(user=request.user).delete()
    return Response(
        {
            "message": "All classification history has been permanently deleted.",
            "deleted_count": count,
        },
        status=status.HTTP_200_OK,
    )



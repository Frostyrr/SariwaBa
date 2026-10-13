import logging
from django.shortcuts import HttpResponse
from django.contrib.auth.models import User
from django.db import transaction

from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import (
    api_view,
    permission_classes,
    parser_classes,
)
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken, TokenError

from PIL import Image, UnidentifiedImageError

from .models import UserProfile, ClassificationHistory
from .services.google_auth_service import verify_google_token

logger = logging.getLogger(__name__)


def _serialize_user(user, profile=None):
    if profile is None:
        profile = getattr(user, 'profile', None)

    return {
        "id": user.id,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "username": user.username,
        "profile_picture": profile.profile_picture if profile else None,
        "is_guest": False,
        "is_registered": True,
    }


def home(request):
    return HttpResponse("SariwaBa Backend is running!")


# Google Authentication Endpoint
@api_view(["POST"])
@permission_classes([AllowAny])
def google_auth(request):
    token = request.data.get("id_token")

    if not token:
        return Response(
            {
                "error": {
                    "code": "MISSING_TOKEN",
                    "message": "ID token is required."
                }
            },
            status=status.HTTP_400_BAD_REQUEST
        )

    google_user = verify_google_token(token)

    if google_user is None:
        return Response(
            {
                "error": {
                    "code": "INVALID_TOKEN",
                    "message": "Invalid or expired Google ID token."
                }
            },
            status=status.HTTP_401_UNAUTHORIZED
        )

    if not google_user.get("email_verified"):
        return Response(
            {
                "error": {
                    "code": "EMAIL_NOT_VERIFIED",
                    "message": "Google account email is not verified."
                }
            },
            status=status.HTTP_401_UNAUTHORIZED
        )

    google_id = google_user.get("google_id")
    email = google_user.get("email")
    full_name = google_user.get("name") or ""
    picture = google_user.get("picture")

    name_parts = full_name.split(" ", 1)
    first_name = name_parts[0] if len(name_parts) > 0 else ""
    last_name = name_parts[1] if len(name_parts) > 1 else ""

    try:
        with transaction.atomic():
            profile = UserProfile.objects.filter(
                google_id=google_id
            ).select_related("user").first()

            if profile:
                user = profile.user
                user.email = email
                user.first_name = first_name
                user.last_name = last_name
                user.save()

                profile.profile_picture = picture
                profile.save()
                created = False
            else:
                user = User.objects.filter(email=email).first()
                if user is None:
                    user = User.objects.create_user(
                        username=email,
                        email=email,
                        first_name=first_name,
                        last_name=last_name,
                    )
                    user.set_unusable_password()
                    user.save()

                profile, _ = UserProfile.objects.update_or_create(
                    user=user,
                    defaults={
                        "google_id": google_id,
                        "profile_picture": picture,
                    }
                )
                created = True

            refresh = RefreshToken.for_user(user)

    except Exception as e:
        logger.exception("Error during Google authentication transaction: %s", e)
        return Response(
            {
                "error": {
                    "code": "AUTHENTICATION_FAILED",
                    "message": "Unable to complete authentication."
                }
            },
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )

    return Response(
        {
            "message": "Authentication successful.",
            "created": created,
            "access": str(refresh.access_token),
            "refresh": str(refresh),
            "user": _serialize_user(user, profile),
        },
        status=status.HTTP_200_OK
    )


# Authenticated User Profile Endpoint
@api_view(["GET"])
@permission_classes([IsAuthenticated])
def profile(request):
    user = request.user
    return Response(
        {
            "user": _serialize_user(user),
        },
        status=status.HTTP_200_OK,
    )


# Logout Endpoint (Blacklists refresh token)
@api_view(["POST"])
@permission_classes([IsAuthenticated])
def logout(request):
    refresh_token = request.data.get("refresh")
    if not refresh_token:
        return Response(
            {
                "error": {
                    "code": "MISSING_REFRESH_TOKEN",
                    "message": "Refresh token is required to logout."
                }
            },
            status=status.HTTP_400_BAD_REQUEST
        )

    try:
        token = RefreshToken(refresh_token)
        token.blacklist()
        return Response(status=status.HTTP_204_NO_CONTENT)
    except TokenError as e:
        return Response(
            {
                "error": {
                    "code": "INVALID_TOKEN",
                    "message": str(e)
                }
            },
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(["POST"])
@permission_classes([AllowAny])
@parser_classes([MultiPartParser, FormParser])
def classify_fish(request):
    image_file = request.FILES.get("image")

    # 1. Image is required
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

    # 2. Maximum file size is 5MB
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

    # 3. Only JPEG and PNG
    allowed_content_types = [
        "image/jpeg",
        "image/png",
    ]


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

    # 4. Verify that the uploaded file is actually an image
    try:
        image = Image.open(image_file)
        image.verify()

        #Reset file pointer after Pillow reads it
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
    

    #------------------------------------
    #TEMPORARY RESULT FOR CLASSIFICATION
    #BEFORE APPLYING MobileNetV3 Model
    #------------------------------------

    label = "Fresh"
    confidence = 0.95

    #------------------------------------
    #Authenticated User -> Save History
    #Guest User -> result only
    #------------------------------------

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
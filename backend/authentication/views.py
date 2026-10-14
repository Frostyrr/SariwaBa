import logging
from django.contrib.auth.models import User
from django.db import transaction

from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import (
    api_view,
    permission_classes,
)
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken, TokenError

from .models import UserProfile
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

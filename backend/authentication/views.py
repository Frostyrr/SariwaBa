import logging
import time
from django.contrib.auth.models import User
from django.db import transaction
from django.utils import timezone

from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import (
    api_view,
    permission_classes,
)
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.tokens import RefreshToken, TokenError
from rest_framework_simplejwt.serializers import TokenRefreshSerializer
from rest_framework_simplejwt.views import TokenRefreshView
from rest_framework.exceptions import AuthenticationFailed

from .models import UserProfile, LoginAuditLog
from .services.google_auth_service import verify_google_token

logger = logging.getLogger(__name__)


def _get_client_ip(request):
    x_forwarded_for = request.META.get("HTTP_X_FORWARDED_FOR")
    if x_forwarded_for:
        return x_forwarded_for.split(",")[0].strip()
    return request.META.get("REMOTE_ADDR")


def _get_user_agent(request):
    return request.META.get("HTTP_USER_AGENT", "")[:500]


def _serialize_user(user, profile=None):
    if profile is None:
        profile = getattr(user, "profile", None)

    return {
        "id": user.id,
        "email": user.email,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "username": user.username,
        "profile_picture": profile.profile_picture if profile else None,
        "role": profile.role if profile else "user",
        "is_admin": profile.is_admin if profile else (user.is_staff or user.is_superuser),
        "is_suspended": profile.is_suspended if profile else False,
        "suspended_at": profile.suspended_at.isoformat() if (profile and profile.suspended_at) else None,
        "date_joined": user.date_joined.isoformat() if getattr(user, "date_joined", None) else None,
        "is_guest": False,
        "is_registered": True,
    }


class SafeTokenRefreshSerializer(TokenRefreshSerializer):
    def validate(self, attrs):
        data = super().validate(attrs)
        try:
            token = RefreshToken(attrs["refresh"])
            user_id = token.payload.get("user_id")
            if user_id:
                profile = UserProfile.objects.filter(user_id=user_id).first()
                if profile and profile.is_suspended:
                    raise AuthenticationFailed("This account has been suspended by an administrator.")
        except AuthenticationFailed:
            raise
        except Exception:
            pass
        return data


class SafeTokenRefreshView(TokenRefreshView):
    serializer_class = SafeTokenRefreshSerializer


# Google Authentication Endpoint
@api_view(["POST"])
@permission_classes([AllowAny])
def google_auth(request):
    client_ip = _get_client_ip(request)
    user_agent = _get_user_agent(request)
    token = request.data.get("id_token")

    if not token:
        LoginAuditLog.objects.create(
            email="",
            ip_address=client_ip,
            user_agent=user_agent,
            status="FAILED_MISSING_TOKEN",
            failure_reason="ID token is required.",
        )
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
        LoginAuditLog.objects.create(
            email="",
            ip_address=client_ip,
            user_agent=user_agent,
            status="FAILED_INVALID_TOKEN",
            failure_reason="Invalid or expired Google ID token.",
        )
        return Response(
            {
                "error": {
                    "code": "INVALID_TOKEN",
                    "message": "Invalid or expired Google ID token."
                }
            },
            status=status.HTTP_401_UNAUTHORIZED
        )

    email = google_user.get("email") or ""

    if not google_user.get("email_verified"):
        LoginAuditLog.objects.create(
            email=email,
            ip_address=client_ip,
            user_agent=user_agent,
            status="FAILED_EMAIL_UNVERIFIED",
            failure_reason="Google account email is not verified.",
        )
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
                if profile.is_suspended:
                    LoginAuditLog.objects.create(
                        email=email,
                        ip_address=client_ip,
                        user_agent=user_agent,
                        status="SUSPENDED_BLOCKED",
                        failure_reason="Account suspended by administrator.",
                    )
                    return Response(
                        {
                            "error": {
                                "code": "ACCOUNT_SUSPENDED",
                                "message": "Your account has been suspended by an administrator."
                            }
                        },
                        status=status.HTTP_403_FORBIDDEN
                    )

                user.email = email
                user.first_name = first_name
                user.last_name = last_name
                user.save()

                profile.profile_picture = picture
                profile.save()
                created = False
            else:
                user = User.objects.filter(email=email).first()
                if user is not None:
                    existing_profile = getattr(user, "profile", None)
                    if existing_profile and existing_profile.is_suspended:
                        LoginAuditLog.objects.create(
                            email=email,
                            ip_address=client_ip,
                            user_agent=user_agent,
                            status="SUSPENDED_BLOCKED",
                            failure_reason="Account suspended by administrator.",
                        )
                        return Response(
                            {
                                "error": {
                                    "code": "ACCOUNT_SUSPENDED",
                                    "message": "Your account has been suspended by an administrator."
                                }
                            },
                            status=status.HTTP_403_FORBIDDEN
                        )

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

            # Record successful login audit
            LoginAuditLog.objects.create(
                email=email,
                ip_address=client_ip,
                user_agent=user_agent,
                status="SUCCESS",
            )

    except Exception as e:
        logger.exception("Error during Google authentication transaction: %s", e)
        LoginAuditLog.objects.create(
            email=email,
            ip_address=client_ip,
            user_agent=user_agent,
            status="ERROR",
            failure_reason="Internal server error during auth.",
        )
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


# Permanent Account Deletion Endpoint
@api_view(["DELETE", "POST"])
@permission_classes([IsAuthenticated])
def delete_account(request):
    user = request.user
    profile = getattr(user, "profile", None)

    # Safety Guard: Prevent deletion of the last active administrator
    if profile and profile.is_admin:
        other_active_admins = UserProfile.objects.filter(
            role="admin",
            is_suspended=False,
        ).exclude(user=user).count()

        if other_active_admins == 0:
            return Response(
                {
                    "error": {
                        "code": "LAST_ADMIN_DELETION_PROHIBITED",
                        "message": "Cannot delete the last active administrator account. Please promote another administrator before deleting this account.",
                    }
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

    email = user.email

    # Append security audit log
    LoginAuditLog.objects.create(
        email=email,
        ip_address=_get_client_ip(request),
        user_agent=_get_user_agent(request),
        status="SUCCESS",
        failure_reason="User requested permanent account deletion.",
    )

    # Clean up associated scan images
    try:
        from classification.models import ClassificationHistory
        scans = list(ClassificationHistory.objects.filter(user=user))
        for scan in scans:
            if scan.image:
                try:
                    scan.image.delete(save=False)
                except Exception:
                    pass
    except Exception:
        pass

    # Permanently delete user (cascades to profile and history records)
    user.delete()

    return Response(
        {
            "message": "Your SariwaBa account and all associated personal records have been permanently deleted.",
        },
        status=status.HTTP_200_OK,
    )


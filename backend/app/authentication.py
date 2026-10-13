from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

from .models import UserProfile
from .services.google_auth_service import verify_google_token


class GoogleIDTokenAuthentication(BaseAuthentication):

    def authenticate(self, request):
        authorization = request.headers.get("Authorization")

        # No token supplied.
        # Allow DRF permission classes to decide whether
        # anonymous access is permitted.
        if not authorization:
            return None

        parts = authorization.split()

        if len(parts) != 2 or parts[0].lower() != "bearer":
            raise AuthenticationFailed(
                "Authorization header must use Bearer token."
            )

        token = parts[1]

        google_user = verify_google_token(token)

        if google_user is None:
            raise AuthenticationFailed(
                "Invalid or expired Google ID token."
            )

        if not google_user.get("email_verified"):
            raise AuthenticationFailed(
                "Google account email is not verified."
            )

        google_id = google_user.get("google_id")

        try:
            profile = UserProfile.objects.select_related("user").get(
                google_id=google_id
            )
        except UserProfile.DoesNotExist:
            raise AuthenticationFailed(
                "User is not registered in SariwaBa."
            )

        return profile.user, token

    def authenticate_header(self, request):
        return "Bearer"
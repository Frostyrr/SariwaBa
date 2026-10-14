import logging
import os

from google.auth.transport import requests
from google.oauth2 import id_token

logger = logging.getLogger(__name__)


def verify_google_token(token):
    google_client_id = os.getenv("GOOGLE_CLIENT_ID")
    if not google_client_id:
        logger.error("GOOGLE_CLIENT_ID is not configured in environment variables.")
        return None

    try:
        user_info = id_token.verify_oauth2_token(
            token,
            requests.Request(),
            google_client_id,
        )

        return {
            "google_id": user_info.get("sub"),
            "email": user_info.get("email"),
            "name": user_info.get("name"),
            "picture": user_info.get("picture"),
            "email_verified": user_info.get("email_verified"),
        }

    except Exception as error:
        logger.warning("Google ID token verification failed: %s", error)
        return None
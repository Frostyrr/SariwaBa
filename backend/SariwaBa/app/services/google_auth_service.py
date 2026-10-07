import os

from google.auth.transport import requests
from google.oauth2 import id_token

GOOGLE_CLIENT_ID = os.getenv('GOOGLE_CLIENT_ID')



def verify_google_token(token):
    try:
        user_info = id_token.verify_oauth2_token(
            token,
            requests.Request(),
            GOOGLE_CLIENT_ID,
        )

        return {
            "google_id": user_info.get("sub"),
            "email": user_info.get("email"),
            "name": user_info.get("name"),
            "picture": user_info.get("picture"),
            "email_verified": user_info.get("email_verified"),
        }

    except ValueError:
        return None
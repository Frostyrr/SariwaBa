from django.shortcuts import render, HttpResponse

from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

from .services.google_auth_service import verify_google_token

# Create your views here.
def home(request):
    return HttpResponse("SariwaBa Backend is running!")


@api_view(["POST"])
def google_auth(request):
    token = request.data.get("id_token")

    if not token:
        return Response(
            {
                "error": {
                    "code" : "MISSING_TOKEN",
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

    return Response(
        {
            "message": "Google token verified successfully.",
            "user": google_user
        },
        status=status.HTTP_200_OK
    )
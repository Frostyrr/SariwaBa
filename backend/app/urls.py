from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    path("", views.home, name="home"),

    path(
        "api/v1/auth/google/",
        views.google_auth,
        name="google-auth",
    ),

    path(
        "api/v1/auth/token/refresh/",
        TokenRefreshView.as_view(),
        name="token-refresh",
    ),

    path(
        "api/v1/auth/logout/",
        views.logout,
        name="logout",
    ),

    path(
        "api/v1/profile/",
        views.profile,
        name="profile",
    ),

    path(
        "api/v1/classify/",
        views.classify_fish,
        name="classify-fish",
    ),
]
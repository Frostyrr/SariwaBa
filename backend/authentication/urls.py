from django.urls import path
from rest_framework_simplejwt.views import TokenRefreshView
from . import views

urlpatterns = [
    path("google/", views.google_auth, name="google-auth"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token-refresh"),
    path("logout/", views.logout, name="logout"),
    path("profile/", views.profile, name="profile"),
]

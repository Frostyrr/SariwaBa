from django.urls import path
from . import views

urlpatterns = [
    path("google/", views.google_auth, name="google-auth"),
    path("token/refresh/", views.SafeTokenRefreshView.as_view(), name="token-refresh"),
    path("logout/", views.logout, name="logout"),
    path("profile/", views.profile, name="profile"),
    path("account/delete/", views.delete_account, name="delete-account"),
]

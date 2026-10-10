from django.urls import path
from . import views

urlpatterns = [
    path("", views.home, name="home"),

    path(
        "api/v1/auth/google/",
        views.google_auth,
        name="google_auth",
    ),

    path(
        "api/v1/profile/",
        views.profile,
        name="profile",
    ),

]
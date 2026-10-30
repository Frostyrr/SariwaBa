from django.urls import path
from . import views

urlpatterns = [
    path("", views.classify_fish, name="classify-fish"),
    #
    #path("history/", views.list_history, name="history-list"),
    #path("history/<int:scan_id>/", views.history_detail, name="history-detail"),
]

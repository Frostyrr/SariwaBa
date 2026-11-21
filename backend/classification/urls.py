from django.urls import path
from . import views

urlpatterns = [
    path("", views.classify_fish, name="classify-fish"),
    path("eye-proposals/", views.eye_proposals, name="eye-proposals"),
    path("history/bulk/", views.bulk_delete_history, name="history-bulk-delete"),
    #
    #path("history/", views.list_history, name="history-list"),
    #path("history/<int:scan_id>/", views.history_detail, name="history-detail"),
]

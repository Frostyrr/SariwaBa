from django.urls import path
from . import admin_views

urlpatterns = [
    path("stats/", admin_views.admin_stats, name="admin-stats"),
    path("users/", admin_views.admin_users, name="admin-users"),
    path("users/<int:user_id>/role/", admin_views.admin_update_user_role, name="admin-user-role"),
    path("users/<int:user_id>/suspend/", admin_views.admin_toggle_suspension, name="admin-user-suspend"),
    path("security/", admin_views.admin_security, name="admin-security"),
    path("health/", admin_views.admin_health, name="admin-health"),
    path("audits/", admin_views.admin_audits, name="admin-audits"),
]

from rest_framework.permissions import BasePermission


class IsAdminRole(BasePermission):
    """
    Allows access only to authenticated users who have an active admin role
    and are not suspended.
    """
    message = "Administrator privileges are required to access this resource."

    def has_permission(self, request, view):
        user = request.user
        if not user or not user.is_authenticated:
            return False

        profile = getattr(user, "profile", None)
        if profile is None:
            return user.is_staff or user.is_superuser

        if profile.is_suspended:
            return False

        return profile.is_admin

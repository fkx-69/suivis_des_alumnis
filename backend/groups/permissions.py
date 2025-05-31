from rest_framework.permissions import BasePermission, SAFE_METHODS

class IsAlumni(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and hasattr(request.user, 'alumni')

class IsEtudiant(BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and hasattr(request.user, 'etudiant')
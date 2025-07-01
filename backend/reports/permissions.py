from rest_framework.permissions import BasePermission
from accounts.models import Role
from django.core.exceptions import PermissionDenied

class IsEtudiantOrAlumni(BasePermission):
    def has_permission(self, request, view):
        role = getattr(request.user, 'role', None)
        print("Rôle dans IsEtudiantOrAlumni :", role)
        return request.user.is_authenticated and role in [Role.ETUDIANT, Role.ALUMNI]
class IsAdmin(BasePermission):
    def has_permission(self, request, view):
        role = getattr(request.user, 'role', None)
        print("Rôle dans IsAdmin :", role)
        return request.user.is_authenticated and role == Role.ADMIN
class IsNotBanned(BasePermission):
    def has_permission(self, request, view):
        if request.user.is_authenticated and request.user.is_banned:
            raise PermissionDenied("Votre compte a été banni par l'administrateur.")
        return True


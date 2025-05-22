from rest_framework.permissions import BasePermission
from accounts.models import Role

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



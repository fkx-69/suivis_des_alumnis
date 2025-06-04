from rest_framework import permissions

class IsEtudiant(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'ETUDIANT'

class IsAlumni(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.role == 'ALUMNI'

class IsOwnerOrReadOnly(permissions.BasePermission):
    """
    L'utilisateur doit être le mentor (propriétaire) de l'objet pour le modifier.
    """

    def has_object_permission(self, request, view, obj):
        # Lecture autorisée pour tout le monde (GET, HEAD, OPTIONS)
        if request.method in permissions.SAFE_METHODS:
            return True
        # Seul le mentor peut modifier (PUT/PATCH/DELETE)
        return obj.mentor == request.user

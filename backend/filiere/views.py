from rest_framework import generics, permissions
from rest_framework.permissions import  AllowAny
from .models import Filiere
from .serializers import FiliereSerializer

class IsAdminUser(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.is_superuser

class FiliereListCreateView(generics.ListCreateAPIView):
    queryset = Filiere.objects.all()
    serializer_class = FiliereSerializer
    permission_classes = [AllowAny]


class FiliereDeleteView(generics.DestroyAPIView):
    queryset = Filiere.objects.all()
    serializer_class = FiliereSerializer
    permission_classes = [IsAdminUser]
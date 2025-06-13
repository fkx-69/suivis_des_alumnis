from rest_framework import generics, permissions
from rest_framework.permissions import AllowAny
from .models import Filiere
from .serializers import FiliereSerializer

from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi


# === Permission personnalisée ===
class IsAdminUser(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user.is_authenticated and request.user.is_superuser


# === Liste et création de filières ===
class FiliereListCreateView(generics.ListCreateAPIView):
    queryset = Filiere.objects.all()
    serializer_class = FiliereSerializer
    permission_classes = [AllowAny]

    @swagger_auto_schema(
        operation_description="Récupère la liste de toutes les filières disponibles.",
        responses={200: FiliereSerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    @swagger_auto_schema(
        operation_description="Créer une nouvelle filière. Accessible sans authentification.",
        request_body=FiliereSerializer,
        responses={201: "Filière créée avec succès"}
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)


# === Suppression d'une filière ===
class FiliereDeleteView(generics.DestroyAPIView):
    queryset = Filiere.objects.all()
    serializer_class = FiliereSerializer
    permission_classes = [IsAdminUser]

    @swagger_auto_schema(
        operation_description="Supprimer une filière. Accessible uniquement aux administrateurs.",
        manual_parameters=[
            openapi.Parameter(
                'pk', openapi.IN_PATH, description="ID de la filière à supprimer", type=openapi.TYPE_INTEGER
            )
        ],
        responses={204: "Filière supprimée", 403: "Non autorisé"}
    )
    def delete(self, request, *args, **kwargs):
        return super().delete(request, *args, **kwargs)

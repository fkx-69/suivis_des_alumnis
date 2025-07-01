from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from django.core.mail import send_mail
from django.conf import settings
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from .models import Report
from .serializers import ReportSerializer
from accounts.models import CustomUser
from .permissions import IsAdmin, IsEtudiantOrAlumni, IsNotBanned

# === Créer un signalement ===
class ReportCreateView(generics.CreateAPIView):
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticated, IsEtudiantOrAlumni, IsNotBanned]

    @swagger_auto_schema(
        operation_description="Permet à un étudiant ou un alumni de signaler un utilisateur.",
        request_body=ReportSerializer,
        responses={201: ReportSerializer}
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def perform_create(self, serializer):
        serializer.save()
        reported_user = serializer.instance.reported_user
        reason = serializer.instance.reason

        send_mail(
            subject="Un utilisateur a été signalé",
            message=(
                f"L'utilisateur {self.request.user.username} a signalé "
                f"{reported_user.username}.\n\nRaison : {reason}"
            ),
            from_email=settings.EMAIL_HOST_USER,
            recipient_list=[settings.ADMIN_EMAIL],
            fail_silently=False,
        )

# === Liste des signalements (admin) ===
class ReportedUsersListView(generics.ListAPIView):
    queryset = Report.objects.all()
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticated, IsAdmin]

    @swagger_auto_schema(
        operation_description="Liste tous les utilisateurs signalés (admin uniquement).",
        responses={200: ReportSerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

# === Bannir un utilisateur ===
@swagger_auto_schema(
    method='post',
    operation_description="Bannir un utilisateur (admin uniquement).",
    manual_parameters=[
        openapi.Parameter('user_id', openapi.IN_PATH, description="ID de l'utilisateur à bannir", type=openapi.TYPE_INTEGER)
    ],
    responses={200: openapi.Response("Utilisateur banni avec succès"), 404: "Utilisateur non trouvé"}
)
@api_view(['POST'])
@permission_classes([IsAuthenticated, IsAdmin])
def ban_user(request, user_id):
    try:
        user = CustomUser.objects.get(id=user_id)
        user.is_banned = True
        user.save()
        return Response({'detail': 'Utilisateur banni avec succès.'}, status=status.HTTP_200_OK)
    except CustomUser.DoesNotExist:
        return Response({'detail': 'Utilisateur non trouvé.'}, status=status.HTTP_404_NOT_FOUND)

# === Supprimer un utilisateur ===
@swagger_auto_schema(
    method='delete',
    operation_description="Supprimer un utilisateur du système (admin uniquement).",
    manual_parameters=[
        openapi.Parameter('user_id', openapi.IN_PATH, description="ID de l'utilisateur à supprimer", type=openapi.TYPE_INTEGER)
    ],
    responses={200: "Utilisateur supprimé avec succès", 404: "Utilisateur non trouvé"}
)
@api_view(['DELETE'])
@permission_classes([IsAuthenticated, IsAdmin])
def delete_user(request, user_id):
    try:
        user = CustomUser.objects.get(id=user_id)
        user.delete()
        return Response({'detail': 'Utilisateur supprimé avec succès.'}, status=status.HTTP_200_OK)
    except CustomUser.DoesNotExist:
        return Response({'detail': 'Utilisateur non trouvé.'}, status=status.HTTP_404_NOT_FOUND)

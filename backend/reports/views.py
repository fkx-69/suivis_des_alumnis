from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from .permissions import IsAdmin
from django.core.mail import send_mail
from django.conf import settings

from .models import Report
from .serializers import ReportSerializer
from accounts.models import CustomUser
from .permissions import IsEtudiantOrAlumni  


# === CRÉER UN SIGNALMENT ===
class ReportCreateView(generics.CreateAPIView):
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticated, IsEtudiantOrAlumni]  

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


# === LISTER LES SIGNALEMENTS ===
class ReportedUsersListView(generics.ListAPIView):
    queryset = Report.objects.all()
    serializer_class = ReportSerializer
    permission_classes = [IsAuthenticated, IsAdmin] 

# === BANNIR UN UTILISATEUR ===
@api_view(['POST'])
@permission_classes([IsAuthenticated, IsAdmin])  
def ban_user(request, username):
    try:
        user = CustomUser.objects.get(username=username)
        user.is_banned = True
        user.save()
        return Response({'detail': 'Utilisateur banni avec succès.'}, status=status.HTTP_200_OK)
    except CustomUser.DoesNotExist:
        return Response({'detail': 'Utilisateur non trouvé.'}, status=status.HTTP_404_NOT_FOUND)


# === SUPPRIMER UN UTILISATEUR ===
@api_view(['DELETE'])
@permission_classes([IsAuthenticated, IsAdmin])  # Seuls admins peuvent supprimer
def delete_user(request, username):
    try:
        user = CustomUser.objects.get(username=username)
        user.delete()
        return Response({'detail': 'Utilisateur supprimé avec succès.'}, status=status.HTTP_200_OK)
    except CustomUser.DoesNotExist:
        return Response({'detail': 'Utilisateur non trouvé.'}, status=status.HTTP_404_NOT_FOUND)

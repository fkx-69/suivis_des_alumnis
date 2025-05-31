from rest_framework import generics, status,serializers
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import MessagePrive
from .serializers import MessagePriveSerializer
from accounts.models import CustomUser
from notifications.utils import envoyer_notification

class EnvoyerMessagePriveView(generics.CreateAPIView):
    queryset = MessagePrive.objects.all()
    serializer_class = MessagePriveSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        destinataire_username = self.request.data.get('destinataire_username')
        try:
            destinataire = CustomUser.objects.get(username=destinataire_username)
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError("Destinataire introuvable.")

        message = serializer.save(expediteur=self.request.user, destinataire=destinataire)

        # 🔔 Notification temps réel via WebSocket
        envoyer_notification(
            destinataire=destinataire,
            message=f"Nouveau message privé de {self.request.user.username}."
        )

class MessagesRecusView(generics.ListAPIView):
    serializer_class = MessagePriveSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return MessagePrive.objects.filter(destinataire=self.request.user).order_by('-date_envoi')

class MessagesEnvoyesView(generics.ListAPIView):
    serializer_class = MessagePriveSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        return MessagePrive.objects.filter(expediteur=self.request.user).order_by('-date_envoi')

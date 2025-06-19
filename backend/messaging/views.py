from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import MessagePrive
from .serializers import MessagePriveSerializer
from accounts.models import CustomUser
from notifications.utils import envoyer_notification

from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi


# === Envoyer un message privé ===
class EnvoyerMessagePriveView(generics.CreateAPIView):
    queryset = MessagePrive.objects.all()
    serializer_class = MessagePriveSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Envoyer un message privé à un utilisateur.",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=["destinataire_username", "contenu"],
            properties={
                "destinataire_username": openapi.Schema(type=openapi.TYPE_STRING, description="Nom d'utilisateur du destinataire"),
                "contenu": openapi.Schema(type=openapi.TYPE_STRING, description="Contenu du message"),
            }
        ),
        responses={
            201: MessagePriveSerializer,
            400: "Destinataire introuvable ou données invalides"
        }
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def perform_create(self, serializer):
        message = serializer.save()
        envoyer_notification(
            destinataire=message.destinataire,
            message=f"Nouveau message privé de {message.expediteur.username}."
        )


# === Voir les messages reçus ===
class MessagesRecusView(generics.ListAPIView):
    serializer_class = MessagePriveSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Lister les messages privés reçus par l'utilisateur connecté.",
        responses={200: MessagePriveSerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    def get_queryset(self):
        return MessagePrive.objects.filter(destinataire=self.request.user).order_by('-date_envoi')


# === Voir les messages envoyés ===
class MessagesEnvoyesView(generics.ListAPIView):
    serializer_class = MessagePriveSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Lister les messages privés envoyés par l'utilisateur connecté.",
        responses={200: MessagePriveSerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    def get_queryset(self):
        return MessagePrive.objects.filter(expediteur=self.request.user).order_by('-date_envoi')

from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from .models import MessagePrive
from .serializers import MessagePriveSerializer
from accounts.models import CustomUser
from rest_framework.views import APIView
from django.db import models
from django.db.models import Q
from .serializers import UtilisateurConverseSerializer
from django.shortcuts import get_object_or_404
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

# === Voir les messages échangés avec un utilisateur ===
class MessagesAvecUtilisateurView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Lister les messages entre l'utilisateur connecté et un autre utilisateur.",
        responses={200: MessagePriveSerializer(many=True)}
    )
    def get(self, request, username):
        autre_utilisateur = get_object_or_404(CustomUser, username=username)
        utilisateur_connecte = request.user

        messages = MessagePrive.objects.filter(
            (models.Q(expediteur=utilisateur_connecte) & models.Q(destinataire=autre_utilisateur)) |
            (models.Q(expediteur=autre_utilisateur) & models.Q(destinataire=utilisateur_connecte))
        ).order_by('date_envoi')

        serializer = MessagePriveSerializer(messages, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
    
# === Liste des utilisateurs avec qui j'ai discuté ===
class ConversationsListView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Lister les utilisateurs avec qui l'utilisateur connecté a déjà échangé des messages, avec le dernier message.",
        responses={200: UtilisateurConverseSerializer(many=True)}
    )
    def get(self, request):
        utilisateur = request.user

        # Obtenir tous les IDs des utilisateurs avec qui j’ai échangé
        ids_utilisateurs = MessagePrive.objects.filter(
            Q(expediteur=utilisateur) | Q(destinataire=utilisateur)
        ).values_list('expediteur', 'destinataire')

        ids_uniques = set()
        for exp_id, dest_id in ids_utilisateurs:
            if exp_id != utilisateur.id:
                ids_uniques.add(exp_id)
            if dest_id != utilisateur.id:
                ids_uniques.add(dest_id)

        utilisateurs = CustomUser.objects.filter(id__in=ids_uniques)
        serializer = UtilisateurConverseSerializer(utilisateurs, many=True, context={'request': request})
        return Response(serializer.data)
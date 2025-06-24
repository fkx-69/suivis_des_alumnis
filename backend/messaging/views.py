from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Q
from django.shortcuts import get_object_or_404

from .models import MessagePrive
from .serializers import MessagePriveSerializer, UtilisateurConverseSerializer
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
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        message = serializer.save()

        envoyer_notification(
            destinataire=message.destinataire,
            message=f"Nouveau message privé de {message.expediteur.username}."
        )

        return Response(self.get_serializer(message).data, status=status.HTTP_201_CREATED)


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
            Q(expediteur=utilisateur_connecte, destinataire=autre_utilisateur) |
            Q(expediteur=autre_utilisateur, destinataire=utilisateur_connecte)
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

from rest_framework import generics, status, serializers
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Q
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
        raw_dest = self.request.data.get('destinataire_username') or self.request.data.get('destinataire')
        if not raw_dest:
            raise serializers.ValidationError("Destinataire introuvable.")

        try:
            if str(raw_dest).isdigit():
                destinataire = CustomUser.objects.get(id=int(raw_dest))
            else:
                destinataire = CustomUser.objects.get(username=raw_dest)
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError("Destinataire introuvable.")

        message = serializer.save(expediteur=self.request.user, destinataire=destinataire)

        # 🔔 Notification en temps réel via WebSocket
        envoyer_notification(
            destinataire=destinataire,
            message=f"Nouveau message privé de {self.request.user.username}."
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


# === Lister les conversations ===
class ConversationsListView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        messages = (
            MessagePrive.objects
            .filter(Q(expediteur=user) | Q(destinataire=user))
            .select_related('expediteur', 'destinataire')
            .order_by('-date_envoi')
        )

        convo_map = {}
        for msg in messages:
            other = msg.destinataire if msg.expediteur == user else msg.expediteur
            if other.id not in convo_map:
                convo_map[other.id] = msg

        data = []
        for other_id, last_msg in convo_map.items():
            other = last_msg.destinataire if last_msg.expediteur == user else last_msg.expediteur
            data.append({
                'id': other.id,
                'username': other.username,
                'prenom': other.prenom,
                'nom': other.nom,
                'photo_profil': other.photo_profil.url if other.photo_profil else None,
                'last_message': MessagePriveSerializer(last_msg).data,
            })

        return Response(data)


# === Voir les messages d'une conversation ===
class MessagesWithUserView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, username):
        try:
            other = CustomUser.objects.get(username=username)
        except CustomUser.DoesNotExist:
            return Response({'detail': 'Utilisateur introuvable.'}, status=status.HTTP_404_NOT_FOUND)

        messages = (
            MessagePrive.objects
            .filter(
                Q(expediteur=request.user, destinataire=other) |
                Q(expediteur=other, destinataire=request.user)
            )
            .order_by('date_envoi')
        )

        serialized = MessagePriveSerializer(messages, many=True).data
        user_data = {
            'id': other.id,
            'username': other.username,
            'prenom': other.prenom,
            'nom': other.nom,
            'photo_profil': other.photo_profil.url if other.photo_profil else None,
        }
        return Response({'user': user_data, 'messages': serialized})

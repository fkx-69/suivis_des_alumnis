from rest_framework import generics, status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Groupe, Message
from .serializers import GroupeSerializer, MessageSerializer
from .permissions import IsAlumni, IsEtudiant
from notifications.utils import envoyer_notification

from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi


# === Création d'un groupe ===
class GroupeCreateView(generics.CreateAPIView):
    queryset = Groupe.objects.all()
    serializer_class = GroupeSerializer
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Créer un nouveau groupe. Accessible aux étudiants et aux alumnis authentifiés.",
        request_body=GroupeSerializer,
        responses={201: "Groupe créé avec succès."}
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def perform_create(self, serializer):
        serializer.save(createur=self.request.user)


# === Rejoindre un groupe ===
class RejoindreGroupeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Rejoindre un groupe existant.",
        manual_parameters=[
            openapi.Parameter('groupe_id', openapi.IN_PATH, description="ID du groupe", type=openapi.TYPE_INTEGER)
        ],
        responses={
            200: "Rejoint avec succès",
            404: "Groupe non trouvé"
        }
    )
    def post(self, request, groupe_id):
        try:
            groupe = Groupe.objects.get(id=groupe_id)
            groupe.membres.add(request.user)
            return Response({'message': f'Rejoint le groupe {groupe.nom_groupe} avec succès.'})
        except Groupe.DoesNotExist:
            return Response({'error': 'Groupe non trouvé.'}, status=status.HTTP_404_NOT_FOUND)


# === Quitter un groupe ===
class QuitterGroupeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Quitter un groupe.",
        manual_parameters=[
            openapi.Parameter('groupe_id', openapi.IN_PATH, description="ID du groupe", type=openapi.TYPE_INTEGER)
        ],
        responses={
            200: "Quitté avec succès",
            404: "Groupe non trouvé"
        }
    )
    def post(self, request, groupe_id):
        try:
            groupe = Groupe.objects.get(id=groupe_id)
            groupe.membres.remove(request.user)
            return Response({'message': f'Quitté le groupe {groupe.nom_groupe} avec succès.'})
        except Groupe.DoesNotExist:
            return Response({'error': 'Groupe non trouvé.'}, status=status.HTTP_404_NOT_FOUND)


# === Liste des membres d'un groupe ===
class ListeMembresView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Voir la liste des membres d’un groupe.",
        manual_parameters=[
            openapi.Parameter('groupe_id', openapi.IN_PATH, description="ID du groupe", type=openapi.TYPE_INTEGER)
        ],
        responses={
            200: "Liste des membres",
            404: "Groupe non trouvé"
        }
    )
    def get(self, request, groupe_id):
        try:
            groupe = Groupe.objects.get(id=groupe_id)
            membres = [user.username for user in groupe.membres.all()]
            return Response({'membres': membres})
        except Groupe.DoesNotExist:
            return Response({'error': 'Groupe non trouvé.'}, status=status.HTTP_404_NOT_FOUND)


# === Envoyer un message dans un groupe ===
class EnvoyerMessageView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Envoyer un message dans un groupe (réservé aux membres du groupe).",
        manual_parameters=[
            openapi.Parameter('groupe_id', openapi.IN_PATH, description="ID du groupe", type=openapi.TYPE_INTEGER)
        ],
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=['contenu'],
            properties={
                'contenu': openapi.Schema(type=openapi.TYPE_STRING, description='Contenu du message')
            }
        ),
        responses={
            201: MessageSerializer,
            400: "Contenu manquant",
            403: "Non autorisé",
            404: "Groupe non trouvé"
        }
    )
    def post(self, request, groupe_id):
        try:
            groupe = Groupe.objects.get(id=groupe_id)
            if request.user not in groupe.membres.all():
                return Response({'error': 'Vous n\'êtes pas membre de ce groupe.'}, status=status.HTTP_403_FORBIDDEN)

            contenu = request.data.get('contenu')
            if not contenu:
                return Response({'error': 'Le contenu du message est requis.'}, status=status.HTTP_400_BAD_REQUEST)

            message = Message.objects.create(
                groupe=groupe,
                auteur=request.user,
                contenu=contenu
            )

            membres_a_notifier = groupe.membres.exclude(id=request.user.id)
            for membre in membres_a_notifier:
                envoyer_notification(
                    membre,
                    f"{request.user.username} a envoyé un message dans le groupe '{groupe.nom_groupe}'."
                )

            serializer = MessageSerializer(message)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except Groupe.DoesNotExist:
            return Response({'error': 'Groupe non trouvé.'}, status=status.HTTP_404_NOT_FOUND)
# === Liste des messages d'un groupe ===
class ListeMessagesView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Voir la liste des messages d’un groupe.",
        manual_parameters=[
            openapi.Parameter('groupe_id', openapi.IN_PATH, description="ID du groupe", type=openapi.TYPE_INTEGER)
        ],
        responses={
            200: MessageSerializer(many=True),
            404: "Groupe non trouvé"
        }
    )
    def get(self, request, groupe_id):
        try:
            groupe = Groupe.objects.get(id=groupe_id)
            messages = Message.objects.filter(groupe=groupe).order_by('-date_envoi')  
            serializer = MessageSerializer(messages, many=True)
            return Response(serializer.data)
        except Groupe.DoesNotExist:
            return Response({'error': 'Groupe non trouvé.'}, status=status.HTTP_404_NOT_FOUND)

# === Liste de tous les groupes ===
class ListeGroupesView(generics.ListAPIView):
    queryset = Groupe.objects.all().order_by('-date_creation')
    serializer_class = GroupeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    @swagger_auto_schema(
        operation_description="Obtenir la liste de tous les groupes existants. "
                              "Le champ `est_membre` indique si l'utilisateur connecté est membre du groupe.",
        responses={
            200: openapi.Response(
                description="Liste des groupes",
                schema=GroupeSerializer(many=True)
            )
        }
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
class MesGroupesView(generics.ListAPIView):
    serializer_class = GroupeSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return self.request.user.groupes_rejoints.all().order_by('-date_creation')

    def get_serializer_context(self):
        context = super().get_serializer_context()
        context['request'] = self.request
        return context

    @swagger_auto_schema(
        operation_description="Lister les groupes rejoints par l’utilisateur connecté.",
        responses={200: GroupeSerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

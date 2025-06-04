from rest_framework import generics, status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Groupe, Message
from .serializers import GroupeSerializer, MessageSerializer
from .permissions import IsAlumni, IsEtudiant
from notifications.utils import envoyer_notification

class GroupeCreateView(generics.CreateAPIView):
    queryset = Groupe.objects.all()
    serializer_class = GroupeSerializer
    permission_classes = [permissions.IsAuthenticated, IsAlumni,IsEtudiant]

    def perform_create(self, serializer):
        serializer.save(createur=self.request.user)

class RejoindreGroupeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, groupe_id):
        try:
            groupe = Groupe.objects.get(id=groupe_id)
            groupe.membres.add(request.user)
            return Response({'message': f'Rejoint le groupe {groupe.nom_groupe} avec succès.'})
        except Groupe.DoesNotExist:
            return Response({'error': 'Groupe non trouvé.'}, status=status.HTTP_404_NOT_FOUND)

class QuitterGroupeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, groupe_id):

        try:
            groupe = Groupe.objects.get(id=groupe_id)
            groupe.membres.remove(request.user)
            return Response({'message': f'Quitté le groupe {groupe.nom_groupe} avec succès.'})
        except Groupe.DoesNotExist:
            return Response({'error': 'Groupe non trouvé.'}, status=status.HTTP_404_NOT_FOUND)

class ListeMembresView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, groupe_id):
        try:
            groupe = Groupe.objects.get(id=groupe_id)
            membres = [user.username for user in groupe.membres.all()]
            return Response({'membres': membres})
        except Groupe.DoesNotExist:
            return Response({'error': 'Groupe non trouvé.'}, status=status.HTTP_404_NOT_FOUND)

class EnvoyerMessageView(APIView):
    permission_classes = [permissions.IsAuthenticated]

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

            # Notifier tous les membres du groupe (en temps réel via WebSocket)
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
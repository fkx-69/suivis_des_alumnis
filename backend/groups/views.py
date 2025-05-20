from rest_framework import generics, status, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Groupe, Message
from .serializers import GroupeSerializer, MessageSerializer
from .permissions import IsAlumni

class GroupeCreateView(generics.CreateAPIView):
    queryset = Groupe.objects.all()
    serializer_class = GroupeSerializer
    permission_classes = [permissions.IsAuthenticated, IsAlumni]

    def perform_create(self, serializer):
        serializer.save(createur=self.request.user)

class RejoindreGroupeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, nom_groupe):
        try:
            groupe = Groupe.objects.get(nom_groupe=nom_groupe)
            groupe.membres.add(request.user)
            return Response({'message': f'Rejoint le groupe {nom_groupe} avec succès.'})
        except Groupe.DoesNotExist:
            return Response({'error': 'Groupe non trouvé.'}, status=status.HTTP_404_NOT_FOUND)

class QuitterGroupeView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, nom_groupe):
        try:
            groupe = Groupe.objects.get(nom_groupe=nom_groupe)
            groupe.membres.remove(request.user)
            return Response({'message': f'Quitté le groupe {nom_groupe} avec succès.'})
        except Groupe.DoesNotExist:
            return Response({'error': 'Groupe non trouvé.'}, status=status.HTTP_404_NOT_FOUND)

class ListeMembresView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, nom_groupe):
        try:
            groupe = Groupe.objects.get(nom_groupe=nom_groupe)
            membres = [user.username for user in groupe.membres.all()]
            return Response({'membres': membres})
        except Groupe.DoesNotExist:
            return Response({'error': 'Groupe non trouvé.'}, status=status.HTTP_404_NOT_FOUND)

class EnvoyerMessageView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, nom_groupe):
        try:
            groupe = Groupe.objects.get(nom_groupe=nom_groupe)
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
            serializer = MessageSerializer(message)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except Groupe.DoesNotExist:
            return Response({'error': 'Groupe non trouvé.'}, status=status.HTTP_404_NOT_FOUND)

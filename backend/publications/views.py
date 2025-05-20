from rest_framework import generics, permissions
from rest_framework.exceptions import PermissionDenied
from .models import Publication, Commentaire
from .serializers import PublicationSerializer, CommentaireSerializer

class PublicationCreateView(generics.CreateAPIView):
    queryset = Publication.objects.all()
    serializer_class = PublicationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(auteur=self.request.user)

class PublicationListView(generics.ListAPIView):
    queryset = Publication.objects.all().order_by('-date_publication')
    serializer_class = PublicationSerializer
    permission_classes = [permissions.IsAuthenticated]

class PublicationDeleteView(generics.DestroyAPIView):
    queryset = Publication.objects.all()
    serializer_class = PublicationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_destroy(self, instance):
        if instance.auteur != self.request.user:
            raise PermissionDenied("Vous ne pouvez supprimer que vos propres publications.")
        instance.delete()

class CommentaireCreateView(generics.CreateAPIView):
    queryset = Commentaire.objects.all()
    serializer_class = CommentaireSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(auteur=self.request.user)

from rest_framework import generics, permissions
from rest_framework.exceptions import PermissionDenied
from .models import Publication, Commentaire
from .serializers import PublicationSerializer, CommentaireSerializer
from notifications.utils import envoyer_notification


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
        commentaire = serializer.save(auteur=self.request.user)
        publication = commentaire.publication

        # Notifier l’auteur de la publication si un autre utilisateur commente
        if commentaire.auteur != publication.auteur:
            envoyer_notification(
                destinataire=publication.auteur,
                message=f"{commentaire.auteur.username} a commenté votre publication."
            )


class CommentaireDeleteView(generics.DestroyAPIView):
    queryset = Commentaire.objects.all()
    serializer_class = CommentaireSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_destroy(self, instance):
        user = self.request.user
        publication = instance.publication

        # Autorisé si c’est ton commentaire OU un commentaire sur ta publication
        if instance.auteur != user and publication.auteur != user:
            raise PermissionDenied("Vous ne pouvez supprimer que vos propres commentaires ou ceux sur vos publications.")

        instance.delete()

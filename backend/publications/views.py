from rest_framework import generics, permissions
from rest_framework.exceptions import PermissionDenied
from rest_framework.response import Response
from .models import Publication, Commentaire
from .serializers import PublicationSerializer, CommentaireSerializer
from django.shortcuts import get_object_or_404
from notifications.utils import envoyer_notification

from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi


# === Créer une publication ===
class PublicationCreateView(generics.CreateAPIView):
    queryset = Publication.objects.all()
    serializer_class = PublicationSerializer
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Créer une nouvelle publication.",
        request_body=PublicationSerializer,
        responses={201: PublicationSerializer}
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def perform_create(self, serializer):
        serializer.save(auteur=self.request.user)


# === Lister les publications ===
class PublicationListView(generics.ListAPIView):
    queryset = Publication.objects.all().order_by('-date_publication')
    serializer_class = PublicationSerializer
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Lister toutes les publications, triées par date décroissante.",
        responses={200: PublicationSerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)


# === Supprimer une publication ===
class PublicationDeleteView(generics.DestroyAPIView):
    queryset = Publication.objects.all()
    serializer_class = PublicationSerializer
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Supprimer une publication (seulement si vous en êtes l'auteur).",
        responses={204: "Publication supprimée avec succès.", 403: "Non autorisé"}
    )
    def delete(self, request, *args, **kwargs):
        return super().delete(request, *args, **kwargs)

    def perform_destroy(self, instance):
        if instance.auteur != self.request.user:
            raise PermissionDenied("Vous ne pouvez supprimer que vos propres publications.")
        instance.delete()


# === Créer un commentaire ===
class CommentaireCreateView(generics.CreateAPIView):
    queryset = Commentaire.objects.all()
    serializer_class = CommentaireSerializer
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Commenter une publication.",
        request_body=CommentaireSerializer,
        responses={201: CommentaireSerializer}
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def perform_create(self, serializer):
        commentaire = serializer.save(auteur=self.request.user)
        publication = commentaire.publication

        # 🔔 Notification à l’auteur si quelqu’un d’autre commente sa publication
        if commentaire.auteur != publication.auteur:
            envoyer_notification(
                destinataire=publication.auteur,
                message=f"{commentaire.auteur.username} a commenté votre publication."
            )


# === Supprimer un commentaire ===
class CommentaireDeleteView(generics.DestroyAPIView):
    queryset = Commentaire.objects.all()
    serializer_class = CommentaireSerializer
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Supprimer un commentaire (le vôtre ou un commentaire sur votre publication).",
        responses={204: "Commentaire supprimé.", 403: "Non autorisé"}
    )
    def delete(self, request, *args, **kwargs):
        return super().delete(request, *args, **kwargs)

    def perform_destroy(self, instance):
        user = self.request.user
        publication = instance.publication

        if instance.auteur != user and publication.auteur != user:
            raise PermissionDenied("Vous ne pouvez supprimer que vos propres commentaires ou ceux sur vos publications.")
        instance.delete()
class PublicationsParUtilisateurView(generics.ListAPIView):
    serializer_class = PublicationSerializer
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Lister les publications d’un utilisateur donné (par son username).",
        responses={200: PublicationSerializer(many=True)}
    )
    def get(self, request, username, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    def get_queryset(self):
        from accounts.models import CustomUser
        username = self.kwargs.get('username')
        utilisateur = get_object_or_404(CustomUser, username=username)
        return Publication.objects.filter(auteur=utilisateur).order_by('-date_publication')

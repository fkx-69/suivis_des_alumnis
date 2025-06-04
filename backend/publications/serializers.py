from rest_framework import serializers
from .models import Publication, Commentaire

class CommentaireSerializer(serializers.ModelSerializer):
    auteur_username = serializers.ReadOnlyField(source='auteur.username')

    class Meta:
        model = Commentaire
        fields = ['id', 'publication', 'auteur_username', 'contenu', 'date_commentaire']

class PublicationSerializer(serializers.ModelSerializer):
    auteur_username = serializers.ReadOnlyField(source='auteur.username')
    commentaires = CommentaireSerializer(many=True, read_only=True)

    class Meta:
        model = Publication
        fields = ['id', 'auteur_username', 'texte', 'photo', 'video', 'date_publication', 'commentaires']

from rest_framework import serializers
from .models import Publication, Commentaire

class CommentaireSerializer(serializers.ModelSerializer):
    auteur_username = serializers.ReadOnlyField(source='auteur.username')
    auteur_photo_profil = serializers.ImageField(source='auteur.photo_profil', read_only=True)
    
    class Meta:
        model = Commentaire
        fields = ['id', 'publication', 'auteur_username','auteur_photo_profil', 'contenu', 'date_commentaire']
    

class PublicationSerializer(serializers.ModelSerializer):
    auteur_username = serializers.ReadOnlyField(source='auteur.username')
    auteur_photo_profil = serializers.ImageField(source='auteur.photo_profil', read_only=True)
    commentaires = CommentaireSerializer(many=True, read_only=True)
    nombres_commentaires = serializers.SerializerMethodField()

    class Meta:
        model = Publication
        fields = ['id', 'auteur_username','auteur_photo_profil', 'texte', 'photo', 'video', 'date_publication', 'commentaires','nombres_commentaires']
    def get_nombres_commentaires(self, obj):
        return obj.commentaires.count()
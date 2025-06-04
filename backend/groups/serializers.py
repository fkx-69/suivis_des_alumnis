from rest_framework import serializers
from .models import Groupe, Message
from django.contrib.auth import get_user_model

User = get_user_model()

class GroupeSerializer(serializers.ModelSerializer):
    createur = serializers.ReadOnlyField(source='createur.username')
    membres = serializers.SlugRelatedField(
        many=True,
        slug_field='username',
        read_only=True
    )

    class Meta:
        model = Groupe
        fields = ['id', 'nom_groupe', 'description', 'createur', 'membres', 'date_creation']

class MessageSerializer(serializers.ModelSerializer):
    auteur = serializers.ReadOnlyField(source='auteur.username')

    class Meta:
        model = Message
        fields = ['id', 'groupe', 'auteur', 'contenu', 'date_envoi']

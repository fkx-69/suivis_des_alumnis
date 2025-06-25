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
    est_membre = serializers.SerializerMethodField()
    role = serializers.SerializerMethodField()  # 👈 nouveau champ

    class Meta:
        model = Groupe
        fields = ['id', 'nom_groupe', 'description', 'createur', 'membres', 'date_creation', 'est_membre', 'role']

    def get_est_membre(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.membres.filter(id=request.user.id).exists()
        return False

    def get_role(self, obj):
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            if obj.createur == request.user:
                return 'createur'
            elif obj.membres.filter(id=request.user.id).exists():
                return 'membre'
        return None

class MessageSerializer(serializers.ModelSerializer):
    auteur = serializers.ReadOnlyField(source='auteur.username')

    class Meta:
        model = Message
        fields = ['id', 'groupe', 'auteur', 'contenu', 'date_envoi']

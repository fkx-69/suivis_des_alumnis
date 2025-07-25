from rest_framework import serializers
from .models import MessagePrive
from accounts.models import CustomUser
from django.db import models

class MessagePriveSerializer(serializers.ModelSerializer):
    expediteur_username = serializers.CharField(source='expediteur.username', read_only=True)
    destinataire_username = serializers.CharField(write_only=True)

    class Meta:
        model = MessagePrive
        fields = [
            'id',
            'expediteur',
            'expediteur_username',
            'destinataire',
            'destinataire_username',
            'contenu',
            'date_envoi'
        ]
        read_only_fields = ['expediteur', 'date_envoi', 'destinataire']
        extra_kwargs = {
            'destinataire': {'read_only': True},
        }

    def create(self, validated_data):
        destinataire_username = validated_data.pop('destinataire_username')
        try:
            destinataire = CustomUser.objects.get(username=destinataire_username)
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError({'destinataire_username': 'Utilisateur introuvable.'})

        return MessagePrive.objects.create(
            expediteur=self.context['request'].user,
            destinataire=destinataire,
            **validated_data
        )
class UtilisateurConverseSerializer(serializers.ModelSerializer):
    last_message = serializers.SerializerMethodField()

    class Meta:
        model = CustomUser
        fields = ['id', 'username', 'prenom', 'nom', 'photo_profil', 'last_message']

    def get_last_message(self, user):
        utilisateur_connecte = self.context['request'].user

        dernier_message = MessagePrive.objects.filter(
            (models.Q(expediteur=utilisateur_connecte, destinataire=user) |
             models.Q(expediteur=user, destinataire=utilisateur_connecte))
        ).order_by('-date_envoi').first()

        if dernier_message:
            return dernier_message.contenu
        return None

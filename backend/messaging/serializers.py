from rest_framework import serializers
from .models import MessagePrive
from accounts.models import CustomUser

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
        read_only_fields = ['expediteur', 'date_envoi', 'expediteur_username', 'destinataire']

    def validate_destinataire_username(self, value):
        try:
            return CustomUser.objects.get(username=value)
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError("Destinataire introuvable.")

    def create(self, validated_data):
        destinataire = validated_data.pop('destinataire_username')
        return MessagePrive.objects.create(
            expediteur=self.context['request'].user,
            destinataire=destinataire,
            **validated_data
        )

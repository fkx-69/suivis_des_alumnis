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

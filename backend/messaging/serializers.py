from rest_framework import serializers
from .models import MessagePrive

class MessagePriveSerializer(serializers.ModelSerializer):
    expediteur_username = serializers.CharField(source='expediteur.username', read_only=True)
    destinataire_username = serializers.CharField(source='destinataire.username', read_only=True)

    class Meta:
        model = MessagePrive
        fields = '__all__'
        read_only_fields = ['expediteur', 'date_envoi']

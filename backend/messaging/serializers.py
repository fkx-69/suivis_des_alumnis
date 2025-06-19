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
        read_only_fields = ['expediteur', 'destinataire', 'date_envoi']

    def create(self, validated_data):
        """Create a ``MessagePrive`` instance.

        ``destinataire`` and ``expediteur`` may be provided explicitly when
        calling ``serializer.save``. If they are not, ``destinataire`` is
        resolved from ``destinataire_username`` and ``expediteur`` defaults to
        the current request user.
        """

        destinataire = validated_data.pop('destinataire', None)
        destinataire_username = validated_data.pop('destinataire_username', None)

        if destinataire is None:
            if not destinataire_username:
                raise serializers.ValidationError({'destinataire_username': 'Ce champ est requis.'})
            try:
                destinataire = CustomUser.objects.get(username=destinataire_username)
            except CustomUser.DoesNotExist:
                raise serializers.ValidationError({'destinataire_username': 'Utilisateur introuvable.'})

        expediteur = validated_data.pop('expediteur', self.context['request'].user)

        return MessagePrive.objects.create(
            expediteur=expediteur,
            destinataire=destinataire,
            **validated_data
        )

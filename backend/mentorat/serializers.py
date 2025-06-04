from rest_framework import serializers
from .models import DemandeMentorat

class DemandeMentoratSerializer(serializers.ModelSerializer):
    etudiant_username = serializers.CharField(source='etudiant.username', read_only=True)
    mentor_username = serializers.CharField(source='mentor.username', read_only=True)

    class Meta:
        model = DemandeMentorat
        fields = [
            'id',
            'etudiant',
            'etudiant_username',
            'mentor',
            'mentor_username',
            'statut',
            'message',
            'motif_refus',
            'date_demande',
            'date_maj'
        ]
        read_only_fields = [
            'etudiant',
            'statut',
            'motif_refus',
            'date_demande',
            'date_maj'
        ]

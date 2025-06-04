from rest_framework import serializers
from .models import Evenement

class EvenementSerializer(serializers.ModelSerializer):
    createur = serializers.ReadOnlyField(source='createur.username')
    date_debut_affiche = serializers.SerializerMethodField()
    date_fin_affiche = serializers.SerializerMethodField()

    class Meta:
        model = Evenement
        fields = [
            'titre',
            'description',
            'date_debut_affiche',
            'date_fin_affiche',
            'createur',
        ]

    def get_date_debut_affiche(self, obj):
        return obj.date_debut.strftime('%d-%m-%Y à %Hh:%M')

    def get_date_fin_affiche(self, obj):
        return obj.date_fin.strftime('%d-%m-%Y à %Hh:%M')

from rest_framework import serializers
from .models import Evenement

class EvenementSerializer(serializers.ModelSerializer):
    createur = serializers.ReadOnlyField(source='createur.username')
    createur_id = serializers.ReadOnlyField(source='createur.id')
    id = serializers.ReadOnlyField()
    valide = serializers.BooleanField(read_only=True)
    date_debut_affiche = serializers.SerializerMethodField()
<<<<<<< HEAD
    date_fin_affiche   = serializers.SerializerMethodField()
=======
    date_fin_affiche = serializers.SerializerMethodField()
    is_owner = serializers.SerializerMethodField()
>>>>>>> a7e021173fac2389d154439f4ce8e9fb288863a0

    class Meta:
        model = Evenement
        fields = [
            'id',
            'titre',
            'description',
<<<<<<< HEAD
            'date_debut',        # <- IMPORTANT
            'date_fin',          # <- IMPORTANT
=======
            'date_debut',
            'date_fin',
>>>>>>> a7e021173fac2389d154439f4ce8e9fb288863a0
            'date_debut_affiche',
            'date_fin_affiche',
            'valide',
            'createur',
<<<<<<< HEAD
            'valide',            # si vous l’utilisez
        ]
        read_only_fields = [
            'id',
            'date_debut_affiche',
            'date_fin_affiche',
            'createur',
            'valide',
=======
            'createur_id',
            'is_owner',
>>>>>>> a7e021173fac2389d154439f4ce8e9fb288863a0
        ]

    def get_date_debut_affiche(self, obj):
        return obj.date_debut.strftime('%d-%m-%Y à %Hh:%M') if obj.date_debut else None

    def get_date_fin_affiche(self, obj):
        return obj.date_fin.strftime('%d-%m-%Y à %Hh:%M') if obj.date_fin else None

    def get_is_owner(self, obj):
        request = self.context.get('request')
        return request.user == obj.createur if request and request.user.is_authenticated else False

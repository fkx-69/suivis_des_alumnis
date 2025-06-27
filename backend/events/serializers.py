from rest_framework import serializers
from .models import Evenement

class EvenementSerializer(serializers.ModelSerializer):
    createur = serializers.ReadOnlyField(source='createur.username')
    createur_id = serializers.ReadOnlyField(source='createur.id')
    id = serializers.ReadOnlyField()
    valide = serializers.BooleanField(read_only=True)
    date_debut_affiche = serializers.SerializerMethodField()
    date_fin_affiche   = serializers.SerializerMethodField()
    is_owner = serializers.SerializerMethodField()
    image = serializers.ImageField(use_url=True, required=False, allow_null=True)

    class Meta:
        model = Evenement
        fields = [
            'id',
            'titre', 
            'description',
            'image',
            'date_debut',       
            'date_fin',          
            'date_debut_affiche',
            'date_fin_affiche',
            'valide',
            'createur',
            'createur_id',
            'is_owner',         
            'valide',           
        ]
        read_only_fields = [
            'id',
            'date_debut_affiche',
            'date_fin_affiche',
            'createur',
            'valide',
        ]

    def get_date_debut_affiche(self, obj):
        return obj.date_debut.strftime('%d-%m-%Y à %Hh:%M') if obj.date_debut else None

    def get_date_fin_affiche(self, obj):
        return obj.date_fin.strftime('%d-%m-%Y à %Hh:%M') if obj.date_fin else None

    def get_is_owner(self, obj):
        request = self.context.get('request')
        return request.user == obj.createur if request and request.user.is_authenticated else False

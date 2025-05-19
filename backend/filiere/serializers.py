from rest_framework import serializers
from .models import Filiere

class FiliereSerializer(serializers.ModelSerializer):
    nombre_etudiants = serializers.IntegerField(read_only=True)

    class Meta:
        model = Filiere
        fields = ['id', 'code', 'nom_complet', 'nombre_etudiants', 'nombre_alumnis']
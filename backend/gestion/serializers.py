from rest_framework import serializers
from .models import ReponseEnquete

class ReponseEnqueteSerializer(serializers.ModelSerializer):
    class Meta:
        model = ReponseEnquete
        exclude = ['alumni']

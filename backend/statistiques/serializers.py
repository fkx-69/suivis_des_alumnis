from rest_framework import serializers

class SituationProStatsSerializer(serializers.Serializer):
    situation = serializers.CharField()
    count = serializers.IntegerField()

class DomaineStatsSerializer(serializers.Serializer):
    domaine = serializers.CharField()
    count = serializers.IntegerField()

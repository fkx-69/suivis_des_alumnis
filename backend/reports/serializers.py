from rest_framework import serializers
from .models import Report
from accounts.models import CustomUser

class ReportSerializer(serializers.ModelSerializer):
    reported_user_id = serializers.IntegerField(write_only=True)
    reported_user = serializers.SerializerMethodField()

    class Meta:
        model = Report
        fields = ['id', 'reported_by', 'reported_user', 'reported_user_id', 'reason', 'created_at']
        read_only_fields = ['reported_by', 'reported_user', 'created_at']

    def get_reported_user(self, obj):
        return {
            "id": obj.reported_user.id,
            "username": obj.reported_user.username,
            "email": obj.reported_user.email,
        }

    def validate_reported_user_id(self, value):
        try:
            return CustomUser.objects.get(id=value)
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError("Utilisateur à signaler non trouvé.")

    def create(self, validated_data):
        reported_user_obj = validated_data.pop('reported_user_id')
        request = self.context['request']
        return Report.objects.create(
            reported_by=request.user,
            reported_user=reported_user_obj,
            **validated_data
        )

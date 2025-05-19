from rest_framework import serializers
from .models import Report
from accounts.models import CustomUser

class ReportSerializer(serializers.ModelSerializer):
    reported_user_username = serializers.CharField(write_only=True)
    reported_user = serializers.SerializerMethodField()

    class Meta:
        model = Report
        fields = ['id', 'reported_by', 'reported_user', 'reported_user_username', 'reason', 'created_at']
        read_only_fields = ['reported_by', 'reported_user', 'created_at']

    def get_reported_user(self, obj):
        return {
            "username": obj.reported_user.username,
            "email": obj.reported_user.email,
        }

    def validate_reported_user_username(self, value):
        try:
            return CustomUser.objects.get(username=value)
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError("Utilisateur à signaler non trouvé.")

    def create(self, validated_data):
        reported_user_obj = validated_data.pop('reported_user_username')
        request = self.context['request']
        return Report.objects.create(
            reported_by=request.user,
            reported_user=reported_user_obj,
            **validated_data
        )

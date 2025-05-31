from rest_framework import generics, permissions
from .models import Notification
from .serializers import NotificationSerializer

class ListeNotificationsView(generics.ListAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Notification.objects.filter(destinataire=self.request.user).order_by('-date')

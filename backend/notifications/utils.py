from .models import Notification
from asgiref.sync import async_to_sync
from channels.layers import get_channel_layer
from .serializers import NotificationSerializer

def envoyer_notification(destinataire, message):
    notification = Notification.objects.create(destinataire=destinataire, message=message)

    # Envoi temps réel via WebSocket
    channel_layer = get_channel_layer()
    group_name = f"user_{destinataire.id}"
    serializer = NotificationSerializer(notification)
    async_to_sync(channel_layer.group_send)(
        group_name,
        {
            'type': 'envoyer_notification',
            'notification': serializer.data
        }
    )

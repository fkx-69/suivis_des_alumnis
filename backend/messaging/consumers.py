import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from .models import MessagePrive
from .serializers import MessagePriveSerializer

User = get_user_model()

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        user = self.scope["user"]
        other_id = self.scope["url_route"]["kwargs"].get("user_id")
        if not user.is_authenticated or other_id is None:
            await self.close()
            return
        self.other_user = await self.get_user(other_id)
        if not self.other_user:
            await self.close()
            return
        ids = sorted([user.id, self.other_user.id])
        self.group_name = f"chat_{ids[0]}_{ids[1]}"
        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, "group_name"):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive(self, text_data=None, bytes_data=None):
        if text_data is None:
            return
        data = json.loads(text_data)
        content = data.get("message")
        if not content:
            return
        message = await self.create_message(self.scope["user"], self.other_user, content)
        serialized = await self.serialize_message(message)
        await self.channel_layer.group_send(
            self.group_name,
            {"type": "chat_message", "message": serialized},
        )

    async def chat_message(self, event):
        await self.send(text_data=json.dumps(event["message"]))

    @database_sync_to_async
    def get_user(self, user_id):
        try:
            return User.objects.get(id=user_id)
        except User.DoesNotExist:
            return None

    @database_sync_to_async
    def create_message(self, sender, recipient, content):
        return MessagePrive.objects.create(expediteur=sender, destinataire=recipient, contenu=content)

    @database_sync_to_async
    def serialize_message(self, message):
        return MessagePriveSerializer(message).data

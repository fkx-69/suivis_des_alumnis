from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
import json

from .models import MessagePrive

User = get_user_model()

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.other_user_id = self.scope["url_route"]["kwargs"].get("user_id")
        self.user = self.scope["user"]
        if not self.user.is_authenticated or self.other_user_id is None:
            await self.close()
            return

        # ensure consistent group name regardless of connection order
        ids = sorted([int(self.user.id), int(self.other_user_id)])
        self.group_name = f"chat_{ids[0]}_{ids[1]}"

        await self.channel_layer.group_add(self.group_name, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, "group_name"):
            await self.channel_layer.group_discard(self.group_name, self.channel_name)

    async def receive(self, text_data=None, bytes_data=None):
        if not text_data:
            return
        data = json.loads(text_data)
        message_text = data.get("message")
        if not message_text:
            return

        message = await self.save_message(message_text)
        event = {
            "type": "chat.message",
            "message": {
                "id": message.id,
                "expediteur": message.expediteur_id,
                "destinataire": message.destinataire_id,
                "contenu": message.contenu,
                "date_envoi": message.date_envoi.isoformat(),
                "expediteur_username": message.expediteur.username,
                "destinataire_username": message.destinataire.username,
            },
        }
        await self.channel_layer.group_send(self.group_name, event)

    async def chat_message(self, event):
        await self.send(text_data=json.dumps(event["message"]))

    @database_sync_to_async
    def save_message(self, content):
        destinataire = User.objects.get(pk=self.other_user_id)
        return MessagePrive.objects.create(
            expediteur=self.user,
            destinataire=destinataire,
            contenu=content,
        )

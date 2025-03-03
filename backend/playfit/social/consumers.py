import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from .models import Notification

class NotificationConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope["user"]
        if self.user.is_authenticated:
            self.room_group_name = f"notifications_{self.user.id}"
            await self.channel_layer.group_add(self.room_group_name, self.channel_name)
            await self.accept()
        else:
            await self.close()

    async def disconnect(self, close_code):
        if self.user.is_authenticated:
            await self.channel_layer.group_discard(self.room_group_name, self.channel_name)

    async def receive(self, text_data):
        data = json.loads(text_data)
        if data.get("action") == "mark_as_seen":
            await self.mark_notifications_as_seen()

    async def send_notification(self, event):
        """ Sends a new notification to the WebSocket """
        await self.send(text_data=json.dumps(event["message"]))

    @database_sync_to_async
    def mark_notifications_as_seen(self):
        Notification.objects.filter(user=self.user, seen=False).update(seen=True)

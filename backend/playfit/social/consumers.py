import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from utilities.redis import redis_client
from .models import Notification
from social.utils import send_notification_async as send_notification_to_user

class NotificationConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.user = self.scope["user"]
        if self.user.is_authenticated:
            self.room_group_name = f"notifications_{self.user.id}"
            await self.channel_layer.group_add(self.room_group_name, self.channel_name)

            redis_client.set(f"user_{self.user.id}", self.channel_name)
            await self.accept()
        else:
            await self.close()

    async def disconnect(self, close_code):
        if self.user.is_authenticated:
            followers = await self.get_followers()

            notifications = await self.create_worldposition_notifications(followers, {
                "sender": self.user,
                "notification_type": "world_position",
                "post": None,
            })
            for follower in followers:
                await send_notification_to_user(follower, {
                    'id': notifications[followers.index(follower)].id,
                    'sender': self.user.username,
                    'notification_type': notifications[followers.index(follower)].notification_type,
                    'created_at': notifications[followers.index(follower)].created_at.isoformat(),
                    'post': None,
                    'seen': notifications[followers.index(follower)].seen,
                })
            redis_client.delete(f"user_{self.user.id}")
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

    @database_sync_to_async
    def get_followers(self):
        if self.user.is_authenticated:
            return list(self.user.get_followers())
        return []

    @database_sync_to_async
    def create_worldposition_notifications(self, followers, notification_data):
        notifications = [
            Notification(
                user=follower,
                sender=notification_data["sender"],
                notification_type=notification_data["notification_type"],
                post=notification_data["post"],
            )
            for follower in followers
        ]
        Notification.objects.bulk_create(notifications)
        return notifications

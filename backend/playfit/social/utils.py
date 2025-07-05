from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync, sync_to_async
from push_notifications.models import GCMDevice
from utilities.redis import redis_client

def send_push_notification(user, title, message):
    devices = GCMDevice.objects.filter(user=user, active=True)

    for device in devices:
        try:
            device.send_message(title=title, message=message)
        except Exception:
            device.active = False
            device.save()

def send_notification(user, notification_data):
    channel_layer = get_channel_layer()
    group_name = f"notifications_{user.id}"

    if redis_client.exists(f"user_{user.id}"):
        async_to_sync(channel_layer.group_send)(
            group_name,
            {
                "type": "send_notification",
                "message": {
                    "data": notification_data,
                },
            },
        )
    else:
        message = ""

        if notification_data["notification_type"] == "like":
            message = f"{notification_data['sender']} liked your post"
        elif notification_data["notification_type"] == "comment":
            message = f"{notification_data['sender']} commented on your post"
        elif notification_data["notification_type"] == "follow":
            message = f"{notification_data['sender']} followed you"
        elif notification_data["notification_type"] == "post":
            message = f"{notification_data['sender']} posted"

        send_push_notification(user, "Playfit", message)

async def send_notification_async(user, notification_data):
    channel_layer = get_channel_layer()
    group_name = f"notifications_{user.id}"

    if redis_client.exists(f"user_{user.id}"):
        await channel_layer.group_send(
            group_name,
            {
                "type": "send_notification",
                "message": {
                    "data": notification_data,
                },
            },
        )
    else:
        message = ""

        if notification_data["notification_type"] == "like":
            message = f"{notification_data['sender']} liked your post"
        elif notification_data["notification_type"] == "comment":
            message = f"{notification_data['sender']} commented on your post"
        elif notification_data["notification_type"] == "follow":
            message = f"{notification_data['sender']} followed you"
        elif notification_data["notification_type"] == "post":
            message = f"{notification_data['sender']} posted"
        elif notification_data["notification_type"] == "world_position":
            message = f"{notification_data['sender']} has completed some workouts"

        await sync_to_async(send_push_notification)(user, "Playfit", message)

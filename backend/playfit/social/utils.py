import sys
from PIL import Image
from io import BytesIO
from django.core.files.base import ContentFile
from django.core.files.uploadedfile import SimpleUploadedFile
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync, sync_to_async
from push_notifications.models import GCMDevice
from utilities.redis import redis_client

def convert_to_webp(image_field):
    """Convert an uploaded image to WebP format."""
    image_field.file.seek(0)
    image = Image.open(image_field)
    image = image.convert("RGBA")

    webp_io = BytesIO()
    image.save(webp_io, format="WEBP")

    filename_without_ext = image_field.name.split('.')[0]
    webp_file = ContentFile(webp_io.getvalue(), f"{filename_without_ext}.webp")
    return webp_file

def create_test_image():
    img = Image.new('RGB', (100, 100), color='red')
    buffer = BytesIO()
    img.save(buffer, format='PNG')
    buffer.seek(0)
    return SimpleUploadedFile("test_image.png", buffer.read(), content_type="image/png")

def send_push_notification(user, title, message):
    devices = GCMDevice.objects.filter(user=user, active=True)

    print(f"Devices: {devices}")
    for device in devices:
        try:
            print(f"Sending push notification to device: {device}")
            device.send_message(title=title, message=message)
            print(f"Push notification sent to device: {device}")
        except Exception as e:
            device.active = False
            device.save()
            print(f"Error sending push notification: {e}")

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

        print(f"User {user.id} is offline, sending notification via push notification of type {notification_data['notification_type']}", file=sys.stderr)
        send_push_notification(user, "Playfit", message)

async def send_notification_async(user, notification_data):
    channel_layer = get_channel_layer()
    group_name = f"notifications_{user.id}"

    if redis_client.exists(f"user_{user.id}"):
        print(f"User {user.id} is online, sending notification via WebSocket")
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
        print(f"User {user.id} is offline, sending notification via push notification")
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

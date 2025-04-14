from datetime import timedelta
from django.utils.timezone import now
from django.core.management.base import BaseCommand
from social.models import Notification
class Command(BaseCommand):
    def handle(self, *args, **kwargs):
        one_month_ago = now() - timedelta(days=30)
        notifications_to_delete = Notification.objects.filter(seen=True, created_at__lt=one_month_ago).delete()
        self.stdout.write(f"{notifications_to_delete} notifications deleted")

from django.core.management.base import BaseCommand
from django.utils.timezone import now, timedelta
from django.core.mail import send_mail
from authentification.models import CustomUser
from django.conf import settings

class Command(BaseCommand):
    help = 'Manage user retention policy'

    def handle(self, *args, **kwargs):
        inactive_users = CustomUser.objects.filter(
            is_active=True,
            last_login__lt=now() - timedelta(days=365),
            scheduled_for_deletion__isnull=True
        )
        for user in inactive_users:
            user.schedule_deletion()
            self.stdout.write(f"Scheduled deletion for {user.username}")

        notify_users = CustomUser.objects.filter(
            scheduled_for_deletion__lte=now() + timedelta(days=30),
            deletion_notified=False
        )
        for user in notify_users:
            self.send_deletion_warning_email(user)
            user.deletion_notified = True
            user.save()
            self.stdout.write(f"Sent deletion notification to {user.username}")

        users_to_delete = CustomUser.objects.filter(
            scheduled_for_deletion__lte=now()
        )
        deleted_count = users_to_delete.count()
        users_to_delete.delete()
        self.stdout.write(f"Deleted {deleted_count} inactive users.")

    def send_deletion_warning_email(self, user):
        send_mail(
            "Your account is scheduled for deletion",
            "Your account has been inactive for 1 year and will be deleted in 30 days. Log in to prevent deletion.",
            "playfit@gmail.com",
            [user.email]
        )

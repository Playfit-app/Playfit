from datetime import timedelta
from django.core.management.base import BaseCommand
from django.utils.timezone import now
from django.core.mail import send_mail
from push_notifications.models import GCMDevice
from authentification.models import UserProgress

class Command(BaseCommand):
    help = "Remind users to workout today to maintain their streak"

    def handle(self, *args, **kwargs):
        today = now().date()
        yesterday = today - timedelta(days=1)

        reminded_users = 0
        for progress in UserProgress.objects.select_related('user').all():
            user = progress.user
            last_workout = progress.last_workout_date.date() if progress.last_workout_date else None

            if last_workout == yesterday and progress.current_streak > 0 and user.is_active:
                devices = GCMDevice.objects.filter(user=user, active=True)

                if devices.exists():
                    for device in devices:
                        try:
                            device.send_message(
                                title="Playfit Reminder",
                                message="Don't forget to workout today to keep your streak going!"
                            )
                        except Exception:
                            device.active = False
                            device.save()

                    # Send email reminder
                    send_mail(
                        subject="Playfit Workout Reminder",
                        message="Don't forget to workout today to keep your streak going!",
                        from_email="playfit.helper@gmail.com",
                        recipient_list=[user.email],
                    )
                    reminded_users += 1
                    self.stdout.write(f"Reminder sent to user: {user.email}")

        self.stdout.write(f"✅ {reminded_users} user(s) reminded to keep their streak.")

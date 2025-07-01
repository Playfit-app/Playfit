from datetime import timedelta
from django.core.management.base import BaseCommand
from django.utils.timezone import now
from authentification.models import UserProgress

class Command(BaseCommand):
    help = "Reset user streaks if they skipped a day"

    def handle(self, *args, **kwargs):
        today = now().date()

        affected_users = 0
        for progress in UserProgress.objects.select_related('user').all():
            last_workout = progress.last_workout_date.date() if progress.last_workout_date else None

            if not last_workout or (last_workout < today - timedelta(days=1)):
                progress.current_streak = 0
                progress.save()
                affected_users += 1
                self.stdout.write(f"Streak reset for user: {progress.user.email}")

        self.stdout.write(f"✅ Finished. {affected_users} user(s) had their streak reset.")

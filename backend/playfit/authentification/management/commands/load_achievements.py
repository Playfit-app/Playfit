from django.core.management.base import BaseCommand
from authentification.models import GameAchievement
class Command(BaseCommand):
    help = "Load predefined achievements into the database"

    def handle(self, *args, **kwargs):
        achievements = [
            {
                "name": "Welcome to Playfit",
                "description": "Welcome to Playfit! We are happy to have you here.",
                "criteria": [{"current_streak": 1}],
                "xp_reward": 50,
            },
            {
                "name": "First Steps",
                "description": "Complete your first workout.",
                "criteria": [{"workouts_completed": 1}],
                "xp_reward": 100,
            },
            {
                "name": "The beginning of a journey",
                "description": "Complete 5 workouts.",
                "criteria": [{"workouts_completed": 5}],
                "xp_reward": 150,
            },
            {
                "name": "Regularity is THE key, week 1",
                "description": "The current streak is 7 days.",
                "criteria": [{"current_streak": 7}],
                "xp_reward": 150,
            },
            {
                "name": "Regularity is THE key, week 2",
                "description": "The current streak is 14 days.",
                "criteria": [{"current_streak": 14}],
                "xp_reward": 200,
            },
            {
                "name": "Regularity is THE key, week 3",
                "description": "The current streak is 21 days.",
                "criteria": [{"current_streak": 21}],
                "xp_reward": 250,
            },
            {
                "name": "Regularity is THE key, month 1",
                "description": "The current streak is 30 days.",
                "criteria": [{"current_streak": 30}],
                "xp_reward": 300,
            },
        ]

        for achievement_data in achievements:
            achievement, created = GameAchievement.objects.update_or_create(
                name=achievement_data["name"],
                defaults=achievement_data
            )
            if created:
                self.stdout.write(self.style.SUCCESS(f"Added achievement: {achievement.name}"))
            else:
                self.stdout.write(self.style.WARNING(f"Updated achievement: {achievement.name}"))

        self.stdout.write(self.style.SUCCESS("Achievement loading complete!"))
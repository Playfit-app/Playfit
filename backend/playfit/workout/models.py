from django.db import models
from authentification.models import CustomUser
from social.models import City

class WorkoutSession(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)

    # World position's snapshot
    city = models.ForeignKey(City, on_delete=models.SET_NULL, null=True, blank=True)
    city_level = models.PositiveIntegerField(null=True, blank=True)
    transition_from = models.ForeignKey(City, related_name='+', on_delete=models.SET_NULL, null=True, blank=True)
    transition_to = models.ForeignKey(City, related_name='+', on_delete=models.SET_NULL, null=True, blank=True)

    duration = models.DurationField(default=0)
    creation_date = models.DateField()
    completed_date = models.DateField(blank=True, null=True)

    def is_in_city(self):
        return self.city is not None

    def is_in_transition(self):
        return self.transition_from is not None and self.transition_to is not None

class Exercise(models.Model):
    DIFFICULTY_CHOICES = [
        ("beginner", "Beginner"),
        ("intermediate", "Intermediate"),
        ("advanced", "Advanced"),
    ]

    name = models.CharField(max_length=30)
    description = models.TextField()
    video_url = models.URLField(blank=True, null=True)
    difficulty = models.CharField(max_length=20, choices=DIFFICULTY_CHOICES)

class WorkoutSessionExercise(models.Model):
    workout_session = models.ForeignKey(WorkoutSession, on_delete=models.CASCADE)
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE)
    sets = models.PositiveIntegerField()
    repetitions = models.PositiveIntegerField()
    weight = models.DecimalField(max_digits=5, decimal_places=2, null=True)

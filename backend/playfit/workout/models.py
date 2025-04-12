from datetime import timedelta
from django.db import models
from django.core.exceptions import ValidationError
from authentification.models import CustomUser
from social.models import City
from social.utils import convert_to_webp

def exercises_image_path(instance, filename):
    filename_without_ext = filename.split('.')[0]
    return f'workout/exercises/{filename_without_ext}.webp'

class WorkoutSession(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)

    # World position's snapshot
    city = models.ForeignKey(City, on_delete=models.SET_NULL, null=True, blank=True)
    city_level = models.PositiveIntegerField(null=True, blank=True)
    transition_from = models.ForeignKey(City, related_name='+', on_delete=models.SET_NULL, null=True, blank=True)
    transition_to = models.ForeignKey(City, related_name='+', on_delete=models.SET_NULL, null=True, blank=True)

    duration = models.DurationField(default=timedelta(minutes=0, seconds=0))
    creation_date = models.DateField()
    completed_date = models.DateField(blank=True, null=True)

    def is_in_city(self):
        return self.city is not None

    def is_in_transition(self):
        return self.transition_from is not None and self.transition_to is not None

class Exercise(models.Model):
    name = models.CharField(max_length=30)
    image = models.ImageField(upload_to=exercises_image_path, blank=True, null=True)

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        if self.image:
            ext = self.image.name.split('.')[-1].lower()
            if ext == 'png':
                self.image = convert_to_webp(self.image)
            elif ext != 'webp':
                raise ValidationError("The image must be a PNG or WebP file")
        super().save(*args, **kwargs)

class WorkoutSessionExercise(models.Model):
    DIFFICULTY_CHOICES = [
        ("beginner", "Beginner"),
        ("intermediate", "Intermediate"),
        ("advanced", "Advanced"),
    ]

    workout_session = models.ForeignKey(WorkoutSession, on_delete=models.CASCADE)
    exercise = models.ForeignKey(Exercise, on_delete=models.CASCADE)
    sets = models.PositiveIntegerField()
    repetitions = models.PositiveIntegerField()
    weight = models.DecimalField(max_digits=5, decimal_places=2, null=True)
    difficulty = models.CharField(max_length=20, choices=DIFFICULTY_CHOICES, default="beginner")

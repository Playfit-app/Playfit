from django.test import SimpleTestCase
from django.urls import resolve, reverse
from workout.views import ExerciseView, WorkoutSessionView

class TestUrls(SimpleTestCase):
    def test_get_exercises_url_resolves(self):
        url = reverse('get_exercises')
        self.assertEqual(resolve(url).func.view_class, ExerciseView)

    def test_add_exercise_url_resolves(self):
        url = reverse('add_exercise')
        self.assertEqual(resolve(url).func.view_class, ExerciseView)

    def test_get_workout_sessions_url_resolves(self):
        url = reverse('get_workout_sessions')
        self.assertEqual(resolve(url).func.view_class, WorkoutSessionView)

    def test_add_workout_session_url_resolves(self):
        url = reverse('add_workout_session')
        self.assertEqual(resolve(url).func.view_class, WorkoutSessionView)

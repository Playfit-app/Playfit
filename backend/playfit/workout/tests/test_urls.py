from django.test import SimpleTestCase
from django.urls import resolve, reverse
from workout.views import ExerciseView

class TestUrls(SimpleTestCase):
    def test_get_exercises_url_resolves(self):
        url = reverse('get_exercises')
        self.assertEqual(resolve(url).func.view_class, ExerciseView)

    def test_add_exercise_url_resolves(self):
        url = reverse('add_exercise')
        self.assertEqual(resolve(url).func.view_class, ExerciseView)

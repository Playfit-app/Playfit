import datetime
from rest_framework import status
from rest_framework.test import APITestCase
from rest_framework.authtoken.models import Token
from authentification.models import CustomUser
from workout.models import Exercise, WorkoutSession

class ExerciseViewTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_superuser(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.exercise = Exercise.objects.create(
            name="Test Exercise",
            image=None
        )
        self.url = "/api/workout/get_exercises/"
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)

    def test_get_exercises(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["name"], "Test Exercise")

    def test_create_exercise(self):
        data = {
            "name": "New Exercise",
            "image": None  # Assuming image is optional for this test
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Exercise.objects.count(), 2)
        self.assertEqual(Exercise.objects.last().name, "New Exercise")

class WorkoutSessionViewTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_superuser(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.exercise = Exercise.objects.create(
            name="Test Exercise",
            image=None
        )
        self.workout_session = WorkoutSession.objects.create(
            user=self.user,
            creation_date=datetime.date.today(),
            duration=datetime.timedelta(minutes=30)
        )
        self.url = "/api/workout/get_workout_sessions/"
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)

    def test_get_workout_sessions(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["date"], datetime.date.today())
        self.assertEqual(response.data[0]["duration"], datetime.timedelta(minutes=30))

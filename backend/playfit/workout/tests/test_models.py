from datetime import timedelta
from django.test import TestCase
from authentification.models import CustomUser
from workout.models import Exercise, WorkoutSession, WorkoutSessionExercise

class ExerciseTest(TestCase):
    def setUp(self):
        self.exercise = Exercise.objects.create(
            name="Test Exercise",
            image=None,
        )

    def test_exercise_creation(self):
        self.assertEqual(self.exercise.name, "Test Exercise")

class WorkoutSessionTest(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            terms_and_conditions=True,
            privacy_policy=True,
            marketing=False
        )
        self.workout_session = WorkoutSession.objects.create(
            user=self.user,
            creation_date="2021-01-01",
            duration=timedelta(minutes=30)
        )

    def test_workout_session_creation(self):
        self.assertEqual(self.workout_session.creation_date, "2021-01-01")
        self.assertEqual(self.workout_session.duration, timedelta(minutes=30))

class WorkoutSessionExerciseTest(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.exercise = Exercise.objects.create(
            name="Test Exercise",
            image=None,
        )
        self.workout_session = WorkoutSession.objects.create(
            user=self.user,
            creation_date="2021-01-01",
            duration=timedelta(minutes=30)
        )
        self.workout_session_exercise = WorkoutSessionExercise.objects.create(
            workout_session=self.workout_session,
            exercise=self.exercise,
            sets=3,
            repetitions=10,
            weight=20,
            difficulty='intermediate'
        )

    def test_workout_session_exercise_creation(self):
        self.assertEqual(self.workout_session_exercise.workout_session, self.workout_session)
        self.assertEqual(self.workout_session_exercise.exercise, self.exercise)
        self.assertEqual(self.workout_session_exercise.sets, 3)
        self.assertEqual(self.workout_session_exercise.repetitions, 10)
        self.assertEqual(self.workout_session_exercise.weight, 20)
        self.assertEqual(self.workout_session_exercise.difficulty, 'intermediate')

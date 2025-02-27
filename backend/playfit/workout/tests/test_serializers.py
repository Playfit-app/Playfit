import datetime
from django.test import TestCase
from authentification.models import CustomUser
from workout.models import Exercise, WorkoutSession, WorkoutSessionExercise
from workout.serializers import ExerciseSerializer, WorkoutSessionSerializer, WorkoutSessionExerciseSerializer

class ExerciseSerializerTest(TestCase):
    def setUp(self):
        self.exercise = Exercise.objects.create(
            name="Test Exercise",
            description="This is a test exercise",
            video_url="https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            difficulty="beginner"
        )

    def test_serialization(self):
        serializer = ExerciseSerializer(self.exercise)
        self.assertEqual(serializer.data["name"], "Test Exercise")
        self.assertEqual(serializer.data["description"], "This is a test exercise")
        self.assertEqual(serializer.data["video_url"], "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        self.assertEqual(serializer.data["difficulty"], "beginner")

    def test_deserialization(self):
        data = {
            "name": "Test Exercise 2",
            "description": "This is another test exercise",
            "video_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "difficulty": "intermediate"
        }
        serializer = ExerciseSerializer(self.exercise, data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)

        exercise = serializer.save()
        self.assertEqual(exercise.name, "Test Exercise 2")
        self.assertEqual(exercise.description, "This is another test exercise")
        self.assertEqual(exercise.video_url, "https://www.youtube.com/watch?v=dQw4w9WgXcQ")
        self.assertEqual(exercise.difficulty, "intermediate")

    def test_validation(self):
        data = {
            "name": "Test Exercise",
            "description": "This is a test exercise",
            "video_url": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            "difficulty": "expert"
        }
        serializer = ExerciseSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("difficulty", serializer.errors)

class WorkoutSessionSerializerTest(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@ŧest.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.workout_session = WorkoutSession.objects.create(
            user=self.user,
            date=datetime.date.today(),
            duration=datetime.timedelta(minutes=30)
        )

    def test_serialization(self):
        serializer = WorkoutSessionSerializer(self.workout_session)
        self.assertEqual(serializer.data["date"], datetime.date.today().isoformat())
        self.assertEqual(serializer.data["duration"], "00:30:00")

    def test_deserialization(self):
        data = {
            "date": datetime.date.today(),
            "duration": "0:45:00"
        }
        serializer = WorkoutSessionSerializer(self.workout_session, data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)

        workout_session = serializer.save(self.user)
        self.assertEqual(workout_session.date, datetime.date.today())
        self.assertEqual(workout_session.duration, datetime.timedelta(minutes=45))

    def test_validation(self):
        data = {
            "user": self.user.id,
            "date": datetime.date.today() + datetime.timedelta(days=1),
            "duration": "0:30:00"
        }
        serializer = WorkoutSessionSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("date", serializer.errors)

        data["date"] = datetime.date.today()
        serializer = WorkoutSessionSerializer(data=data)
        self.assertTrue(serializer.is_valid())

    def test_save(self):
        data = {
            "date": datetime.date.today(),
            "duration": "0:30:00"
        }
        serializer = WorkoutSessionSerializer(data=data)
        self.assertTrue(serializer.is_valid())

        workout_session = serializer.save(self.user)
        self.assertEqual(workout_session.user, self.user)
        self.assertEqual(workout_session.date, datetime.date.today())
        self.assertEqual(workout_session.duration, datetime.timedelta(minutes=30))

class WorkoutSessionExerciseSerializerTest(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@ŧest.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.exercise = Exercise.objects.create(
            name="Test Exercise",
            description="This is a test exercise",
            video_url="https://www.youtube.com/watch?v=dQw4w9WgXcQ",
            difficulty="beginner"
        )
        self.workout_session = WorkoutSession.objects.create(
            user=self.user,
            date=datetime.date.today(),
            duration=datetime.timedelta(minutes=30)
        )
        self.workout_session_exercise = WorkoutSessionExercise.objects.create(
            workout_session=self.workout_session,
            exercise=self.exercise,
            sets=3,
            repetitions=10
        )

    def test_serialization(self):
        serializer = WorkoutSessionExerciseSerializer(self.workout_session_exercise)
        self.assertEqual(serializer.data["workout_session"], self.workout_session.id)
        self.assertEqual(serializer.data["exercise"], self.exercise.id)
        self.assertEqual(serializer.data["sets"], 3)
        self.assertEqual(serializer.data["repetitions"], 10)

    def test_deserialization(self):
        data = {
            "workout_session": self.workout_session.id,
            "exercise": self.exercise.id,
            "sets": 4,
            "repetitions": 12
        }
        serializer = WorkoutSessionExerciseSerializer(self.workout_session_exercise, data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)

        workout_session_exercise = serializer.save()
        self.assertEqual(workout_session_exercise.workout_session, self.workout_session)
        self.assertEqual(workout_session_exercise.exercise, self.exercise)
        self.assertEqual(workout_session_exercise.sets, 4)
        self.assertEqual(workout_session_exercise.repetitions, 12)

    def test_validation(self):
        data = {
            "workout_session": self.workout_session.id,
            "exercise": self.exercise.id,
            "sets": 3,
            "repetitions": 0
        }
        serializer = WorkoutSessionExerciseSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("repetitions", serializer.errors)

        data["repetitions"] = 10
        serializer = WorkoutSessionExerciseSerializer(data=data)
        self.assertTrue(serializer.is_valid())

    def test_save(self):
        data = {
            "workout_session": self.workout_session.id,
            "exercise": self.exercise.id,
            "sets": 3,
            "repetitions": 10
        }
        serializer = WorkoutSessionExerciseSerializer(data=data)
        self.assertTrue(serializer.is_valid())

        workout_session_exercise = serializer.save()
        self.assertEqual(workout_session_exercise.workout_session, self.workout_session)
        self.assertEqual(workout_session_exercise.exercise, self.exercise)
        self.assertEqual(workout_session_exercise.sets, 3)
        self.assertEqual(workout_session_exercise.repetitions, 10)

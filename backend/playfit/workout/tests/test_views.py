import datetime
from decimal import Decimal
from unittest.mock import patch, MagicMock
from django.utils.timezone import now
from rest_framework import status
from rest_framework.test import APITestCase
from rest_framework.authtoken.models import Token
from authentification.models import CustomUser, UserProgress, UserAchievement, GameAchievement
from social.models import WorldPosition, City, Country, Continent, Post, Notification
from workout.models import Exercise, WorkoutSession, WorkoutSessionExercise


class ExerciseViewTests(APITestCase):
    def setUp(self):
        self.staff_user = CustomUser.objects.create_superuser(
            email="staff@test.com",
            username="staff",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.regular_user = CustomUser.objects.create_user(
            email="user@test.com",
            username="user",
            password="test12345",
            date_of_birth="1990-01-01",
            height=170,
            weight=70,
        )
        self.exercise1 = Exercise.objects.create(
            name="pushUp",
            image=None
        )
        self.exercise2 = Exercise.objects.create(
            name="squat",
            image=None
        )
        self.exercise3 = Exercise.objects.create(
            name="jumpingJack",
            image=None
        )
        self.url = "/api/workout/get_exercises/"

    def test_get_all_exercises_authenticated(self):
        token = Token.objects.create(user=self.regular_user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 3)
        exercise_names = [ex["name"] for ex in response.data]
        self.assertIn("pushUp", exercise_names)
        self.assertIn("squat", exercise_names)
        self.assertIn("jumpingJack", exercise_names)

    def test_get_exercises_filtered_by_name(self):
        token = Token.objects.create(user=self.regular_user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        
        response = self.client.get(self.url, {"exercises": "push,squat"})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertGreaterEqual(len(response.data), 2)

    def test_get_exercises_unauthenticated(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_create_exercise_as_staff(self):
        token = Token.objects.create(user=self.staff_user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        
        data = {
            "name": "New Exercise",
            "image": None
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(Exercise.objects.count(), 4)
        self.assertEqual(response.data["name"], "New Exercise")

    def test_create_exercise_as_regular_user(self):
        token = Token.objects.create(user=self.regular_user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        
        data = {
            "name": "New Exercise",
            "image": None
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        self.assertEqual(Exercise.objects.count(), 3)


class WorkoutSessionsViewTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        
        # Create required geographical objects
        self.continent = Continent.objects.create(name="Europe")
        self.country = Country.objects.create(name="France", continent=self.continent)
        self.city = City.objects.create(name="Paris", country=self.country, order=1, max_level=6)
        
        # Create world position for user
        self.world_position = WorldPosition.objects.create(
            user=self.user,
            city=self.city,
            city_level=1
        )
        
        # Create user progress
        self.user_progress = UserProgress.objects.create(
            user=self.user,
            longest_streak=0,
            current_streak=0,
            cities_finished=0,
            level=1,
            xp=0
        )
        
        self.exercise = Exercise.objects.create(
            name="Test Exercise",
            image=None
        )
        self.workout_session = WorkoutSession.objects.create(
            user=self.user,
            city=self.city,
            city_level=1,
            creation_date=datetime.date.today(),
            duration=datetime.timedelta(minutes=30)
        )
        self.workout_session_exercise = WorkoutSessionExercise.objects.create(
            workout_session=self.workout_session,
            exercise=self.exercise,
            sets=3,
            repetitions=10,
            weight=Decimal('0.00'),
            difficulty="beginner"
        )
        
        self.url = "/api/workout/get_workout_sessions/"
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)

    def test_get_all_workout_sessions(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(len(response.data[0]["exercises"]), 1)
        self.assertEqual(response.data[0]["exercises"][0]["name"], "Test Exercise")

    def test_get_workout_sessions_filtered_by_date(self):
        today = datetime.date.today()
        response = self.client.get(self.url, {"date": today.isoformat()})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)

    @patch('social.utils.send_notification')
    def test_patch_workout_session_in_city_beginner(self, mock_send_notification):
        # Create followers for notification testing
        follower = CustomUser.objects.create_user(
            email="follower@test.com",
            username="follower",
            password="test12345",
            date_of_birth="1990-01-01",
            height=175,
            weight=75,
        )
        
        # Mock the get_followers method
        with patch.object(self.user, 'get_followers', return_value=[follower]):
            data = {"difficulty": "beginner"}
            response = self.client.patch(self.url, data, format='json')
            
            self.assertEqual(response.status_code, status.HTTP_200_OK)
            self.assertEqual(response.data, "Workout session updated successfully")
            
            # Check that workout session was completed
            self.workout_session.refresh_from_db()
            self.assertEqual(self.workout_session.completed_date, now().date())
            
            # Check that world position was updated
            self.world_position.refresh_from_db()
            self.assertEqual(self.world_position.city_level, 2)
            
            # Check that post was created
            self.assertTrue(Post.objects.filter(user=self.user).exists())

    def test_patch_workout_session_invalid_difficulty(self):
        data = {"difficulty": "invalid"}
        response = self.client.patch(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data, "Invalid difficulty")

    def test_patch_workout_session_missing_difficulty(self):
        data = {}
        response = self.client.patch(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data, "Difficulty not found")

    def test_patch_workout_session_not_found(self):
        # Create user without workout session
        user2 = CustomUser.objects.create_user(
            email="test2@test.com",
            username="test2",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        WorldPosition.objects.create(
            user=user2,
            city=self.city,
            city_level=1
        )
        UserProgress.objects.create(
            user=user2,
            longest_streak=0,
            current_streak=0,
            cities_finished=0,
            level=1,
            xp=0
        )
        
        token2 = Token.objects.create(user=user2)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token2.key)
        
        data = {"difficulty": "beginner"}
        response = self.client.patch(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertEqual(response.data, "Workout session not found")

    def test_patch_workout_session_in_transition(self):
        # Update world position to be in transition
        city2 = City.objects.create(name="London", country=self.country, order=2, max_level=6)
        self.world_position.city = None
        self.world_position.city_level = None
        self.world_position.transition_from = self.city
        self.world_position.transition_to = city2
        self.world_position.transition_level = 1
        self.world_position.save()
        
        # Create workout session for transition
        transition_workout = WorkoutSession.objects.create(
            user=self.user,
            transition_from=self.city,
            transition_to=city2,
            creation_date=datetime.date.today(),
            duration=datetime.timedelta(minutes=30)
        )
        WorkoutSessionExercise.objects.create(
            workout_session=transition_workout,
            exercise=self.exercise,
            sets=3,
            repetitions=10,
            weight=Decimal('0.00'),
            difficulty="intermediate"
        )
        
        with patch.object(self.user, 'get_followers', return_value=[]):
            data = {"difficulty": "intermediate"}
            response = self.client.patch(self.url, data, format='json')
            
            self.assertEqual(response.status_code, status.HTTP_200_OK)


class WorkoutSessionExerciseViewTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        
        # Create required geographical objects
        self.continent = Continent.objects.create(name="Europe")
        self.country = Country.objects.create(name="France", continent=self.continent)
        self.city = City.objects.create(name="Paris", country=self.country, order=1, max_level=6)
        
        # Create world position for user
        self.world_position = WorldPosition.objects.create(
            user=self.user,
            city=self.city,
            city_level=1
        )
        
        # Create exercises
        self.exercise_push = Exercise.objects.create(name="pushUp", image=None)
        self.exercise_squat = Exercise.objects.create(name="squat", image=None)
        self.exercise_jumping = Exercise.objects.create(name="jumpingJack", image=None)
        
        self.url = "/api/workout/get_workout_session_exercises/"
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)

    def test_get_workout_session_exercises_existing_session(self):
        # Create existing workout session
        workout_session = WorkoutSession.objects.create(
            user=self.user,
            city=self.city,
            city_level=1,
            creation_date=now().date()
        )
        
        # Create workout session exercises for all difficulties
        for difficulty, reps in [("beginner", 3), ("intermediate", 7), ("advanced", 15)]:
            WorkoutSessionExercise.objects.create(
                workout_session=workout_session,
                exercise=self.exercise_push,
                sets=1,
                repetitions=reps,
                weight=Decimal('0.00'),
                difficulty=difficulty
            )
        
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Check response structure
        self.assertIn('beginner', response.data)
        self.assertIn('intermediate', response.data)
        self.assertIn('advanced', response.data)
        
        # Check beginner exercises
        self.assertEqual(len(response.data['beginner']), 1)
        self.assertEqual(response.data['beginner'][0]['name'], 'pushUp')
        self.assertEqual(response.data['beginner'][0]['repetitions'], 3)

    def test_get_workout_session_exercises_auto_generate(self):
        # No existing workout session - should auto-generate
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Check that workout session was created
        self.assertTrue(WorkoutSession.objects.filter(user=self.user).exists())
        
        # Check response structure
        self.assertIn('beginner', response.data)
        self.assertIn('intermediate', response.data)
        self.assertIn('advanced', response.data)
        
        # Check that all three exercises are included for each difficulty
        for difficulty in ['beginner', 'intermediate', 'advanced']:
            self.assertEqual(len(response.data[difficulty]), 3)
            exercise_names = [ex['name'] for ex in response.data[difficulty]]
            self.assertIn('pushUp', exercise_names)
            self.assertIn('squat', exercise_names)
            self.assertIn('jumpingJack', exercise_names)

    def test_get_workout_session_exercises_in_transition(self):
        # Update world position to be in transition
        city2 = City.objects.create(name="London", country=self.country, order=2, max_level=6)
        self.world_position.city = None
        self.world_position.city_level = None
        self.world_position.transition_from = self.city
        self.world_position.transition_to = city2
        self.world_position.transition_level = 1
        self.world_position.save()
        
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Check that workout session was created for transition
        workout_session = WorkoutSession.objects.get(user=self.user)
        self.assertEqual(workout_session.transition_from, self.city)
        self.assertEqual(workout_session.transition_to, city2)

    def test_get_workout_session_exercises_missing_exercise(self):
        # Delete one of the required exercises
        self.exercise_push.delete()
        
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
        self.assertEqual(response.data, "Exercise not found")

    def test_get_workout_session_exercises_unauthenticated(self):
        self.client.credentials()  # Remove authentication
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

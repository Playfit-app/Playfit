from datetime import timedelta, date
from decimal import Decimal
from django.test import TestCase
from django.core.exceptions import ValidationError
from django.core.files.uploadedfile import SimpleUploadedFile
from unittest.mock import patch, MagicMock
from authentification.models import CustomUser
from social.models import City, Country, Continent
from workout.models import Exercise, WorkoutSession, WorkoutSessionExercise, exercises_image_path


class ExerciseImagePathTest(TestCase):
    """Test the exercises_image_path function"""
    
    def test_exercises_image_path_with_extension(self):
        """Test that the path function correctly formats the path with webp extension"""
        instance = MagicMock()
        filename = "test_exercise.png"
        expected_path = "workout/exercises/test_exercise.webp"
        
        result = exercises_image_path(instance, filename)
        
        self.assertEqual(result, expected_path)
    
    def test_exercises_image_path_multiple_dots(self):
        """Test path function with filename containing multiple dots"""
        instance = MagicMock()
        filename = "test.exercise.image.jpg"
        # The function uses split('.')[0] which takes only the first part
        expected_path = "workout/exercises/test.webp"
        
        result = exercises_image_path(instance, filename)
        
        self.assertEqual(result, expected_path)


class ExerciseTest(TestCase):
    """Test the Exercise model"""
    
    def setUp(self):
        self.exercise_data = {
            'name': 'Test Exercise',
        }
    
    def test_exercise_creation_without_image(self):
        """Test creating an exercise without an image"""
        exercise = Exercise.objects.create(**self.exercise_data)
        
        self.assertEqual(exercise.name, 'Test Exercise')
        self.assertIsNone(exercise.image.name if exercise.image else None)
    
    def test_exercise_str_method(self):
        """Test the __str__ method returns the exercise name"""
        exercise = Exercise.objects.create(**self.exercise_data)
        
        self.assertEqual(str(exercise), 'Test Exercise')
    
    @patch('workout.models.convert_to_webp')
    def test_exercise_save_with_png_image(self, mock_convert):
        """Test saving exercise with PNG image calls convert_to_webp"""
        # Create a real file-like object for the mock to return
        mock_webp_file = SimpleUploadedFile(
            "converted.webp", 
            b"fake_webp_content", 
            content_type="image/webp"
        )
        mock_convert.return_value = mock_webp_file
        
        png_image = SimpleUploadedFile(
            "test.png", 
            b"fake_png_content", 
            content_type="image/png"
        )
        
        exercise = Exercise(name="Test Exercise", image=png_image)
        exercise.save()
        
        # Verify convert_to_webp was called with the PNG image
        mock_convert.assert_called_once_with(png_image)
        # Verify the exercise was saved successfully
        self.assertTrue(exercise.image.name.endswith('.webp'))
    
    def test_exercise_save_with_webp_image(self):
        """Test saving exercise with WebP image doesn't call convert_to_webp"""
        webp_image = SimpleUploadedFile(
            "test.webp", 
            b"fake_webp_content", 
            content_type="image/webp"
        )
        
        with patch('workout.models.convert_to_webp') as mock_convert:
            exercise = Exercise(name="Test Exercise", image=webp_image)
            exercise.save()
            
            mock_convert.assert_not_called()
    
    def test_exercise_save_with_invalid_image_format(self):
        """Test saving exercise with invalid image format raises ValidationError"""
        jpg_image = SimpleUploadedFile(
            "test.jpg", 
            b"fake_jpg_content", 
            content_type="image/jpeg"
        )
        
        exercise = Exercise(name="Test Exercise", image=jpg_image)
        
        with self.assertRaises(ValidationError) as context:
            exercise.save()
        
        self.assertIn("The image must be a PNG or WebP file", str(context.exception))


class WorkoutSessionTest(TestCase):
    """Test the WorkoutSession model"""
    
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="testuser",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            terms_and_conditions=True,
            privacy_policy=True,
            marketing=False
        )
        
        # Create proper continent, country, and cities for testing
        self.continent = Continent.objects.create(name="Test Continent")
        self.country = Country.objects.create(
            name="Test Country",
            continent=self.continent
        )
        self.city1 = City.objects.create(
            name="Test City 1",
            country=self.country,
            order=1
        )
        self.city2 = City.objects.create(
            name="Test City 2", 
            country=self.country,
            order=2
        )
    
    def test_workout_session_creation_minimal(self):
        """Test creating a workout session with minimal required fields"""
        workout_session = WorkoutSession.objects.create(
            user=self.user,
            creation_date=date(2024, 1, 1)
        )
        
        self.assertEqual(workout_session.user, self.user)
        self.assertEqual(workout_session.creation_date, date(2024, 1, 1))
        self.assertEqual(workout_session.duration, timedelta(minutes=0, seconds=0))
        self.assertIsNone(workout_session.completed_date)
        self.assertIsNone(workout_session.city)
        self.assertIsNone(workout_session.city_level)
        self.assertIsNone(workout_session.transition_from)
        self.assertIsNone(workout_session.transition_to)
    
    def test_workout_session_creation_full(self):
        """Test creating a workout session with all fields"""
        workout_session = WorkoutSession.objects.create(
            user=self.user,
            city=self.city1,
            city_level=5,
            transition_from=self.city1,
            transition_to=self.city2,
            duration=timedelta(minutes=45, seconds=30),
            creation_date=date(2024, 1, 1),
            completed_date=date(2024, 1, 2)
        )
        
        self.assertEqual(workout_session.user, self.user)
        self.assertEqual(workout_session.city, self.city1)
        self.assertEqual(workout_session.city_level, 5)
        self.assertEqual(workout_session.transition_from, self.city1)
        self.assertEqual(workout_session.transition_to, self.city2)
        self.assertEqual(workout_session.duration, timedelta(minutes=45, seconds=30))
        self.assertEqual(workout_session.creation_date, date(2024, 1, 1))
        self.assertEqual(workout_session.completed_date, date(2024, 1, 2))
    
    def test_is_in_city_method_true(self):
        """Test is_in_city method returns True when city is set"""
        workout_session = WorkoutSession.objects.create(
            user=self.user,
            city=self.city1,
            creation_date=date(2024, 1, 1)
        )
        
        self.assertTrue(workout_session.is_in_city())
    
    def test_is_in_city_method_false(self):
        """Test is_in_city method returns False when city is None"""
        workout_session = WorkoutSession.objects.create(
            user=self.user,
            creation_date=date(2024, 1, 1)
        )
        
        self.assertFalse(workout_session.is_in_city())
    
    def test_is_in_transition_method_true(self):
        """Test is_in_transition method returns True when both transition cities are set"""
        workout_session = WorkoutSession.objects.create(
            user=self.user,
            transition_from=self.city1,
            transition_to=self.city2,
            creation_date=date(2024, 1, 1)
        )
        
        self.assertTrue(workout_session.is_in_transition())
    
    def test_is_in_transition_method_false_no_cities(self):
        """Test is_in_transition method returns False when no transition cities are set"""
        workout_session = WorkoutSession.objects.create(
            user=self.user,
            creation_date=date(2024, 1, 1)
        )
        
        self.assertFalse(workout_session.is_in_transition())
    
    def test_is_in_transition_method_false_partial(self):
        """Test is_in_transition method returns False when only one transition city is set"""
        workout_session = WorkoutSession.objects.create(
            user=self.user,
            transition_from=self.city1,
            creation_date=date(2024, 1, 1)
        )
        
        self.assertFalse(workout_session.is_in_transition())
        
        workout_session2 = WorkoutSession.objects.create(
            user=self.user,
            transition_to=self.city2,
            creation_date=date(2024, 1, 2)
        )
        
        self.assertFalse(workout_session2.is_in_transition())


class WorkoutSessionExerciseTest(TestCase):
    """Test the WorkoutSessionExercise model"""
    
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="testuser",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            terms_and_conditions=True,
            privacy_policy=True,
            marketing=False
        )
        
        self.exercise = Exercise.objects.create(
            name="Test Exercise"
        )
        
        self.workout_session = WorkoutSession.objects.create(
            user=self.user,
            creation_date=date(2024, 1, 1),
            duration=timedelta(minutes=30)
        )
    
    def test_workout_session_exercise_creation_minimal(self):
        """Test creating a workout session exercise with minimal required fields"""
        wse = WorkoutSessionExercise.objects.create(
            workout_session=self.workout_session,
            exercise=self.exercise,
            sets=3,
            repetitions=10
        )
        
        self.assertEqual(wse.workout_session, self.workout_session)
        self.assertEqual(wse.exercise, self.exercise)
        self.assertEqual(wse.sets, 3)
        self.assertEqual(wse.repetitions, 10)
        self.assertIsNone(wse.weight)
        self.assertEqual(wse.difficulty, "beginner")  # default value
    
    def test_workout_session_exercise_creation_full(self):
        """Test creating a workout session exercise with all fields"""
        wse = WorkoutSessionExercise.objects.create(
            workout_session=self.workout_session,
            exercise=self.exercise,
            sets=4,
            repetitions=12,
            weight=Decimal('25.50'),
            difficulty='advanced'
        )
        
        self.assertEqual(wse.workout_session, self.workout_session)
        self.assertEqual(wse.exercise, self.exercise)
        self.assertEqual(wse.sets, 4)
        self.assertEqual(wse.repetitions, 12)
        self.assertEqual(wse.weight, Decimal('25.50'))
        self.assertEqual(wse.difficulty, 'advanced')
    
    def test_workout_session_exercise_difficulty_choices(self):
        """Test all difficulty choices are valid"""
        difficulties = ['beginner', 'intermediate', 'advanced']
        
        for difficulty in difficulties:
            wse = WorkoutSessionExercise.objects.create(
                workout_session=self.workout_session,
                exercise=self.exercise,
                sets=3,
                repetitions=10,
                difficulty=difficulty
            )
            
            self.assertEqual(wse.difficulty, difficulty)
    
    def test_workout_session_exercise_related_name(self):
        """Test the related_name 'exercises' works correctly"""
        wse1 = WorkoutSessionExercise.objects.create(
            workout_session=self.workout_session,
            exercise=self.exercise,
            sets=3,
            repetitions=10
        )
        
        wse2 = WorkoutSessionExercise.objects.create(
            workout_session=self.workout_session,
            exercise=self.exercise,
            sets=4,
            repetitions=12
        )
        
        exercises = self.workout_session.exercises.all()
        self.assertEqual(exercises.count(), 2)
        self.assertIn(wse1, exercises)
        self.assertIn(wse2, exercises)
    
    def test_workout_session_exercise_cascade_delete(self):
        """Test that deleting workout session deletes related exercises"""
        wse = WorkoutSessionExercise.objects.create(
            workout_session=self.workout_session,
            exercise=self.exercise,
            sets=3,
            repetitions=10
        )
        
        workout_session_id = self.workout_session.id
        wse_id = wse.id
        
        # Delete the workout session
        self.workout_session.delete()
        
        # Check that the workout session exercise was also deleted
        with self.assertRaises(WorkoutSessionExercise.DoesNotExist):
            WorkoutSessionExercise.objects.get(id=wse_id)
    
    def test_workout_session_exercise_exercise_cascade_delete(self):
        """Test that deleting exercise deletes related workout session exercises"""
        wse = WorkoutSessionExercise.objects.create(
            workout_session=self.workout_session,
            exercise=self.exercise,
            sets=3,
            repetitions=10
        )
        
        wse_id = wse.id
        
        # Delete the exercise
        self.exercise.delete()
        
        # Check that the workout session exercise was also deleted
        with self.assertRaises(WorkoutSessionExercise.DoesNotExist):
            WorkoutSessionExercise.objects.get(id=wse_id)

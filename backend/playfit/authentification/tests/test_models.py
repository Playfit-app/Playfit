import datetime
from django.core.exceptions import ValidationError
from authentification.models import (
    CustomUser,
    UserConsent,
    GameAchievement,
    UserAchievement,
    UserProgress,
)
from workout.models import WorkoutSession, WorkoutSessionExercise, Exercise
from tests.utils import make_image_file
from tests.base import BaseAPITestCase

class CustomUserTest(BaseAPITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        # Setup anonymous user
        self.anonymous_user = CustomUser.objects.create_user(
            email="anon@test.com",
            username=None,
            password="anon12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )

    def test_user_creation(self):
        self.assertEqual(self.user.email, "test@test.com")
        self.assertEqual(self.user.username, "test")
        self.assertEqual(self.user.date_of_birth, "1990-01-01")
        self.assertEqual(self.user.height, 180)
        self.assertEqual(self.user.weight, 80)

    def test_user_str(self):
        self.assertEqual(str(self.user), "test")

    def test_anonymous_user_str(self):
        self.assertEqual(str(self.anonymous_user), "Anonymous User 2")

    def test_user_has_perm(self):
        self.assertFalse(self.user.has_perm("auth.view_user"))
        self.assertFalse(self.anonymous_user.has_perm("auth.view_user"))

    def test_user_has_module_perms(self):
        self.assertFalse(self.user.has_module_perms("auth"))
        self.assertFalse(self.anonymous_user.has_module_perms("auth"))

    def test_clean_user_creation(self):
        user = CustomUser(
            email="clean@test.com",
            username="clean",
            password="clean12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        user.clean()
        self.assertIsNone(user.id)
        user.save()
        self.assertIsNotNone(user.id)

    def test_clean_user_creation_wrong_birthdate_format(self):
        user = CustomUser(
            email="clean@test.com",
            username="clean",
            password="clean12345",
            date_of_birth="01-01-1990",
            height=180,
            weight=80,
        )
        with self.assertRaises(ValidationError):
            user.clean()

    def test_clean_user_creation_minor(self):
        user = CustomUser(
            email="minor@test.com",
            username="minor",
            password="minor12345",
            date_of_birth="2010-01-01",
            height=150,
            weight=50,
        )
        with self.assertRaises(ValidationError):
            user.clean()

    def test_clean_user_creation_date_format(self):
        # Should be date.date format
        user = CustomUser(
            email="date_format@test.com",
            username="date_format",
            password="date_format12345",
            date_of_birth=datetime.date(1990, 1, 1),
            height=180,
            weight=80,
        )
        user.clean()
        user.save()
        self.assertIsNotNone(user.id)

    def test_get_posts(self):
        posts = self.user.get_posts()
        self.assertIsInstance(list(posts), list)

class UserConsentTest(BaseAPITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.consent = UserConsent.objects.create(
            user=self.user,
            terms_and_conditions=True,
            privacy_policy=True,
            marketing=False,
        )

    def test_consent_creation(self):
        self.assertEqual(self.consent.user, self.user)
        self.assertTrue(self.consent.terms_and_conditions)
        self.assertTrue(self.consent.privacy_policy)
        self.assertFalse(self.consent.marketing)

    def test_consent_str(self):
        self.assertEqual(str(self.consent), f"Consent for {self.user.username} - {self.consent.consent_date}")

class GameAchievementTest(BaseAPITestCase):
    def setUp(self):
        self.game_achievement = GameAchievement.objects.create(
            name="Test Achievement",
            description="This is a test achievement.",
            type="reps",
            target=100,
            image=make_image_file(),
            xp_reward=50,
        )

    def test_achievement_creation(self):
        self.assertEqual(self.game_achievement.name, "Test Achievement")
        self.assertEqual(self.game_achievement.description, "This is a test achievement.")
        self.assertEqual(self.game_achievement.type, "reps")
        self.assertEqual(self.game_achievement.target, 100)
        self.assertIsNotNone(self.game_achievement.image)
        self.assertEqual(self.game_achievement.xp_reward, 50)

    def test_achievement_str(self):
        self.assertEqual(str(self.game_achievement), "Test Achievement")

    def test_achievement_save(self):
        self.game_achievement.save()
        self.assertIsNotNone(self.game_achievement.id)

class UserAchievementTest(BaseAPITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        UserProgress.objects.create(user=self.user)
        test_image = make_image_file()
        game_achievements = [
            GameAchievement.objects.create(
                name="Test Achievement Reps",
                description="This is a test achievement for reps.",
                type="reps",
                target=100,
                image=test_image,
                xp_reward=50,
            ),
            GameAchievement.objects.create(
                name="Test Achievement Workouts",
                description="This is a test achievement for workouts.",
                type="workouts",
                target=5,
                image=test_image,
                xp_reward=50,
            ),
            GameAchievement.objects.create(
                name="Test Achievement Level",
                description="This is a test achievement for level.",
                type="level",
                target=10,
                image=test_image,
                xp_reward=50,
            ),
            GameAchievement.objects.create(
                name="Test Achievement Duration",
                description="This is a test achievement for duration.",
                type="duration",
                target=300,
                image=test_image,
                xp_reward=50,
            ),
            GameAchievement.objects.create(
                name="Test Achievement Calories",
                description="This is a test achievement for calories.",
                type="calories",
                target=500,
                image=test_image,
                xp_reward=50,
            ),
            GameAchievement.objects.create(
                name="Test Achievement Active Days",
                description="This is a test achievement for active days.",
                type="active_days",
                target=30,
                image=test_image,
                xp_reward=50,
            ),
            GameAchievement.objects.create(
                name="Test Achievement Pushups",
                description="This is a test achievement for pushups.",
                type="pushups",
                target=100,
                image=test_image,
                xp_reward=50,
            ),
            GameAchievement.objects.create(
                name="Test Achievement Squats",
                description="This is a test achievement for squats.",
                type="squats",
                target=100,
                image=test_image,
                xp_reward=50,
            ),
            GameAchievement.objects.create(
                name="Test Achievement Pullups",
                description="This is a test achievement for pullups.",
                type="pullups",
                target=100,
                image=test_image,
                xp_reward=50,
            ),
            GameAchievement.objects.create(
                name="Test Achievement Jumping Jacks",
                description="This is a test achievement for jumping jacks.",
                type="jumping_jacks",
                target=100,
                image=test_image,
                xp_reward=50,
            )
        ]
        for achievement in game_achievements:
            UserAchievement.objects.create(
                user=self.user,
                achievement=achievement,
                is_completed=False,
                current_value=0,
            )
        self.workout_session = WorkoutSession.objects.create(
            user=self.user,
            creation_date="1990-10-10",
        )
        exercises = [
            Exercise.objects.create(name="pushUp", image=test_image),
            Exercise.objects.create(name="squat", image=test_image),
            Exercise.objects.create(name="pullUp", image=test_image),
            Exercise.objects.create(name="jumpingJack", image=test_image),
        ]
        for exercise in exercises:
            WorkoutSessionExercise.objects.create(
                workout_session=self.workout_session,
                exercise=exercise,
                repetitions=10,
                sets=1,
                difficulty="beginner",
            )

    def test_user_achievement_creation(self):
        user_achievement = UserAchievement.objects.first()
        self.assertIsNotNone(user_achievement)
        self.assertEqual(user_achievement.user, self.user)
        self.assertEqual(user_achievement.achievement, GameAchievement.objects.first())
        self.assertFalse(user_achievement.is_completed)
        self.assertEqual(user_achievement.current_value, 0)
        self.assertIsNone(user_achievement.awarded_at)

    def test_update_progress_reps(self):
        user_achievement = UserAchievement.objects.get(achievement__type="reps")
        self.assertIsNotNone(user_achievement)
        self.assertEqual(user_achievement.current_value, 0)
        user_achievement.update_progress(self.workout_session)
        self.assertEqual(user_achievement.current_value, 40)

    def test_update_progress_workouts(self):
        user_achievement = UserAchievement.objects.get(achievement__type="workouts")
        self.assertIsNotNone(user_achievement)
        self.assertEqual(user_achievement.current_value, 0)
        user_achievement.update_progress(self.workout_session)
        self.assertEqual(user_achievement.current_value, 1)

    def test_update_progress_level(self):
        user_achievement = UserAchievement.objects.get(achievement__type="level")
        self.assertIsNotNone(user_achievement)
        self.assertEqual(user_achievement.current_value, 0)
        user_achievement.update_progress(self.workout_session)
        self.assertEqual(user_achievement.current_value, 1)

    def test_update_progress_duration(self):
        user_achievement = UserAchievement.objects.get(achievement__type="duration")
        self.assertIsNotNone(user_achievement)
        self.assertEqual(user_achievement.current_value, 0)
        user_achievement.update_progress(self.workout_session)
        self.assertEqual(user_achievement.current_value, 0)

    def test_update_progress_calories(self):
        user_achievement = UserAchievement.objects.get(achievement__type="calories")
        self.assertIsNotNone(user_achievement)
        self.assertEqual(user_achievement.current_value, 0)
        user_achievement.update_progress(self.workout_session)
        self.assertEqual(user_achievement.current_value, 0)

    def test_update_progress_active_days(self):
        user_achievement = UserAchievement.objects.get(achievement__type="active_days")
        self.assertIsNotNone(user_achievement)
        self.assertEqual(user_achievement.current_value, 0)
        user_achievement.update_progress(self.workout_session)
        self.assertEqual(user_achievement.current_value, 0)

    def test_update_progress_pushups(self):
        user_achievement = UserAchievement.objects.get(achievement__type="pushups")
        self.assertIsNotNone(user_achievement)
        self.assertEqual(user_achievement.current_value, 0)
        user_achievement.update_progress(self.workout_session)
        self.assertEqual(user_achievement.current_value, 10)

    def test_update_progress_squats(self):
        user_achievement = UserAchievement.objects.get(achievement__type="squats")
        self.assertIsNotNone(user_achievement)
        self.assertEqual(user_achievement.current_value, 0)
        user_achievement.update_progress(self.workout_session)
        self.assertEqual(user_achievement.current_value, 10)

    def test_update_progress_pullups(self):
        user_achievement = UserAchievement.objects.get(achievement__type="pullups")
        self.assertIsNotNone(user_achievement)
        self.assertEqual(user_achievement.current_value, 0)
        user_achievement.update_progress(self.workout_session)
        self.assertEqual(user_achievement.current_value, 10)

    def test_update_progress_jumping_jacks(self):
        user_achievement = UserAchievement.objects.get(achievement__type="jumping_jacks")
        self.assertIsNotNone(user_achievement)
        self.assertEqual(user_achievement.current_value, 0)
        user_achievement.update_progress(self.workout_session)
        self.assertEqual(user_achievement.current_value, 10)

class UserProgressTest(BaseAPITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.user_progress = UserProgress.objects.create(
            user=self.user,
            longest_streak=0,
            current_streak=0,
            cities_finished=0,
        )

    def test_user_progress_creation(self):
        self.assertEqual(self.user_progress.user, self.user)
        self.assertEqual(self.user_progress.longest_streak, 0)
        self.assertEqual(self.user_progress.current_streak, 0)
        self.assertEqual(self.user_progress.cities_finished, 0)

    def test_user_progress_str(self):
        self.assertEqual(str(self.user_progress), "Stats for test")

    def test_update_after_workout(self):
        self.user_progress.update_after_workout()
        self.assertEqual(self.user_progress.current_streak, 1)
        self.assertEqual(self.user_progress.longest_streak, 1)
        self.assertEqual(self.user_progress.cities_finished, 0)

    def test_add_xp(self):
        self.user_progress.add_xp(100)
        self.assertEqual(self.user_progress.xp, 100)

    def test_add_lots_of_xp(self):
        self.user_progress.add_xp(2000)
        self.assertEqual(self.user_progress.level, 4)

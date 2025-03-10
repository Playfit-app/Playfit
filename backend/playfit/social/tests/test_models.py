import tempfile
import shutil
from django.test import TestCase, override_settings
from social.models import Follow, CustomizationItem, Customization
from authentification.models import CustomUser
from social.utils import create_test_image

TEMP_MEDIA_ROOT = tempfile.mkdtemp()

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationItemTest(TestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_create_customization_item(self):
        image = create_test_image()
        item = CustomizationItem.objects.create(
            name="Test",
            category="hat",
            image=image,
        )
        self.assertEqual(item.name, "Test")
        self.assertEqual(item.category, "hat")
        self.assertTrue(item.image.name.endswith(".webp"))

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationTest(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.item = CustomizationItem.objects.create(
            name="Test",
            category="hat",
            image=create_test_image(),
        )
        self.customization = Customization.objects.create(
            user=self.user,
            hat=self.item,
        )

    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_create_customization(self):
        self.assertEqual(self.customization.user, self.user)
        self.assertEqual(self.customization.hat, self.item)
        self.assertEqual(self.customization.backpack, None)
        self.assertEqual(self.customization.shirt, None)
        self.assertEqual(self.customization.pants, None)
        self.assertEqual(self.customization.shoes, None)
        self.assertEqual(self.customization.gloves, None)

class FollowTest(TestCase):
    def setUp(self):
        self.user1 = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.user2 = CustomUser.objects.create_user(
            email="test2@test.com",
            username="test2",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.follow = Follow.objects.create(
            follower=self.user1,
            following=self.user2,
        )

    def test_follow_creation(self):
        self.assertEqual(self.follow.follower, self.user1)
        self.assertEqual(self.follow.following, self.user2)

    def test_follow_str(self):
        self.assertEqual(str(self.follow), "test follows test2")

    def test_follow_unique(self):
        with self.assertRaises(Exception):
            Follow.objects.create(
                follower=self.user1,
                following=self.user2,
            )

    def test_follow_self(self):
        with self.assertRaises(Exception):
            Follow.objects.create(
                follower=self.user1,
                following=self.user1,
            )

    def test_follow_delete(self):
        self.follow.delete()
        self.assertEqual(Follow.objects.count(), 0)

import tempfile
import shutil
from django.test import TestCase, override_settings
from social.serializers import (
    CustomizationItemSerializer,
    CustomizationSerializer,
)
from social.models import CustomizationItem, Customization
from authentification.models import CustomUser
from social.utils import create_test_image

TEMP_MEDIA_ROOT = tempfile.mkdtemp()

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationItemSerializerTest(TestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_customization_item_serializer(self):
        item = CustomizationItem.objects.create(
            name="Test",
            category="hat",
            image=create_test_image(),
        )
        serializer = CustomizationItemSerializer(item)
        self.assertEqual(serializer.data["name"], "Test")
        self.assertEqual(serializer.data["category"], "hat")
        self.assertTrue(serializer.data["image"].endswith(".webp"))

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationSerializerTest(TestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_customization_serializer(self):
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        item = CustomizationItem.objects.create(
            name="Test",
            category="hat",
            image=create_test_image(),
        )
        customization = Customization.objects.create(
            user=user,
            hat=item,
        )
        serializer = CustomizationSerializer(customization)
        self.assertEqual(serializer.data["hat"]["name"], "Test")
        self.assertEqual(serializer.data["hat"]["category"], "hat")
        self.assertTrue(serializer.data["hat"]["image"].endswith(".webp"))

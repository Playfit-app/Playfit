import tempfile
import shutil
from rest_framework import status
from rest_framework.test import APITestCase
from django.test import override_settings
from social.models import CustomizationItem, Customization, BaseCharacter
from utilities.images import create_test_image
from authentification.models import CustomUser

TEMP_MEDIA_ROOT = tempfile.mkdtemp()

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationItemListViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_get_customization_items(self):
        CustomizationItem.objects.create(
            name="Test",
            category="hat",
            image=create_test_image(),
        )
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.client.force_authenticate(user=user)
        response = self.client.get("/api/social/customization-items/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["name"], "Test")
        self.assertEqual(response.data[0]["category"], "hat")
        self.assertTrue(response.data[0]["image"].endswith(".webp"))

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationItemByCategoryListViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_get_customization_items_by_category(self):
        CustomizationItem.objects.create(
            name="Test",
            category="hat",
            image=create_test_image(),
        )
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.client.force_authenticate(user=user)
        response = self.client.get("/api/social/customization-items/hat/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 1)
        self.assertEqual(response.data[0]["name"], "Test")
        self.assertEqual(response.data[0]["category"], "hat")
        self.assertTrue(response.data[0]["image"].endswith(".webp"))

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationUpdateViewTests(APITestCase):
    def test_update_customization(self):
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        base_character = BaseCharacter.objects.create(
            name="character_image",
            image=create_test_image(),
        )
        Customization.objects.create(
            user=user,
        )
        data = {
            'base_character': base_character.name,
        }
        self.client.force_authenticate(user=user)
        response = self.client.patch("/api/social/update-customization/", data)
        self.assertEqual(response.status_code, status.HTTP_200_OK)

@override_settings(MEDIA_ROOT=TEMP_MEDIA_ROOT)
class CustomizationViewTests(APITestCase):
    @classmethod
    def tearDownClass(cls):
        shutil.rmtree(TEMP_MEDIA_ROOT, ignore_errors=True)

    def test_get_customization(self):
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        base_character = BaseCharacter.objects.create(
            name="character_image",
            image=create_test_image(),
        )
        Customization.objects.create(
            user=user,
            base_character=base_character,
        )
        self.client.force_authenticate(user=user)
        response = self.client.get("/api/social/customization/")
        self.assertEqual(response.status_code, status.HTTP_200_OK)

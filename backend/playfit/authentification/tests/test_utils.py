from django.test import TestCase
from authentification.utils import generate_username_with_number, generate_uid_from_id, get_id_from_uid
from authentification.models import CustomUser

class GenerateUsernameTestCase(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="testuser_12345",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )

    def test_generate_unique_username(self):
        new_username = generate_username_with_number("testuser")

        self.assertNotEqual(new_username, "testuser_12345")
        self.assertTrue(new_username.startswith("testuser_"))

class UidTestCase(TestCase):
    def test_generate_uid_from_id(self):
        uid = generate_uid_from_id(1)
        self.assertEqual(uid, "AQAAAA")

    def test_get_id_from_uid(self):
        id = get_id_from_uid("AQAAAA")
        self.assertEqual(id, 1)

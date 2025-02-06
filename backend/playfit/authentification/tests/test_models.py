from django.test import TestCase
from authentification.models import CustomUser, UserConsent

class CustomUserTest(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
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

class UserConsentTest(TestCase):
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


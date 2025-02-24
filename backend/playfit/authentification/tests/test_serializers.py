from django.test import TestCase
from authentification.models import CustomUser, UserConsent
from authentification.serializers import CustomUserSerializer, UserConsentSerializer, CustomUserRetrieveSerializer, CustomUserUpdateSerializer,\
                                        CustomUserDeleteSerializer, AccountRecoveryRequestSerializer

class CustomUserSerializerTest(TestCase):
    def test_serialization(self):
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        serializer = CustomUserSerializer(user)
        self.assertEqual(serializer.data["email"], "test@test.com")
        self.assertEqual(serializer.data["username"], "test")
        self.assertEqual(serializer.data["date_of_birth"], "1990-01-01")
        self.assertEqual(serializer.data["height"], "180.00")
        self.assertEqual(serializer.data["weight"], "80.00")

    def test_deserialization(self):
        data = {
            "email": "test@test.com",
            "username": "test",
            "password": "test12345",
            "date_of_birth": "1990-01-01",
            "height": 180,
            "weight": 80,
            "terms_and_conditions": True,
            "privacy_policy": True,
            "marketing": False,
        }
        serializer = CustomUserSerializer(data=data)
        self.assertTrue(serializer.is_valid())

        user = serializer.save()
        self.assertEqual(user.email, "test@test.com")
        self.assertEqual(user.username, "test")
        self.assertEqual(user.date_of_birth, "1990-01-01")
        self.assertEqual(user.height, 180)
        self.assertEqual(user.weight, 80)
        self.assertTrue(user.check_password("test12345"))

    def test_validation(self):
        data = {
            "email": "test@test.com",
            "username": "test",
            "password": "test",
            "date_of_birth": "1990-01-01",
            "height": 180,
            "weight": 80,
            "terms_and_conditions": True,
            "privacy_policy": True,
            "marketing": False,
        }
        serializer = CustomUserSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("non_field_errors", serializer.errors)

        data["password"] = "test12345"
        serializer = CustomUserSerializer(data=data)
        self.assertTrue(serializer.is_valid())

        data["terms_and_conditions"] = False
        serializer = CustomUserSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("non_field_errors", serializer.errors)

        data["terms_and_conditions"] = True
        data["privacy_policy"] = False
        serializer = CustomUserSerializer(data=data)
        self.assertFalse(serializer.is_valid())
        self.assertIn("non_field_errors", serializer.errors)

class UserConsentSerializerTest(TestCase):
    @classmethod
    def setUpTestData(cls):
        cls.user = CustomUser.objects.create(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )

    def test_serialization(self):
        consent = UserConsent.objects.create(
            user=self.user,
            terms_and_conditions=True,
            privacy_policy=True,
            marketing=False,
        )
        serializer = UserConsentSerializer(consent)
        self.assertEqual(serializer.data["terms_and_conditions"], True)
        self.assertEqual(serializer.data["privacy_policy"], True)
        self.assertEqual(serializer.data["marketing"], False)

    def test_deserialization(self):
        data = {
            "terms_and_conditions": True,
            "privacy_policy": True,
            "marketing": False,
        }
        serializer = UserConsentSerializer(data=data)
        self.assertTrue(serializer.is_valid())

        consent = serializer.save(user=self.user)
        self.assertEqual(consent.terms_and_conditions, True)
        self.assertEqual(consent.privacy_policy, True)
        self.assertEqual(consent.marketing, False)

class CustomUserRetrieveSerializerTest(TestCase):
    def test_serialization(self):
        user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        serializer = CustomUserRetrieveSerializer(user)
        self.assertEqual(serializer.data["email"], "test@test.com")
        self.assertEqual(serializer.data["username"], "test")
        self.assertEqual(serializer.data["date_of_birth"], "1990-01-01")
        self.assertEqual(serializer.data["height"], "180.00")
        self.assertEqual(serializer.data["weight"], "80.00")

class CustomUserUpdateSerializerTest(TestCase):
    @classmethod
    def setUpTestData(cls):
        cls.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )

    def test_serialization(self):
        serializer = CustomUserUpdateSerializer(self.user)
        self.assertEqual(serializer.data["username"], "test")
        self.assertEqual(serializer.data["first_name"], None)
        self.assertEqual(serializer.data["last_name"], None)
        self.assertEqual(serializer.data["height"], "180.00")
        self.assertEqual(serializer.data["weight"], "80.00")
        self.assertEqual(serializer.data["goals"], CustomUser.BODYWEIGHT_STRENGTH)
        self.assertEqual(serializer.data["gender"], "other")
        self.assertEqual(serializer.data["fitness_level"], "beginner")
        self.assertEqual(serializer.data["physical_particularities"], None)

    def test_deserialization(self):
        data = {
            "username": "test2",
            "first_name": "Test",
            "last_name": "Test",
            "height": 170,
            "weight": 70,
            "goals": CustomUser.BODYWEIGHT_STRENGTH,
            "gender": "other",
            "fitness_level": "beginner",
            "physical_particularities": None,
        }
        serializer = CustomUserUpdateSerializer(self.user, data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)

        user = serializer.save()
        self.assertEqual(user.username, "test2")
        self.assertEqual(user.first_name, "Test")
        self.assertEqual(user.last_name, "Test")
        self.assertEqual(user.height, 170)
        self.assertEqual(user.weight, 70)
        self.assertEqual(user.goals, CustomUser.BODYWEIGHT_STRENGTH)
        self.assertEqual(user.gender, "other")
        self.assertEqual(user.fitness_level, "beginner")

class CustomUserDeleteSerializerTest(TestCase):
    def test_deserialization(self):
        data = {
            "confirm": True,
        }
        serializer = CustomUserDeleteSerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        self.assertTrue(serializer.validated_data["confirm"])

class AccountRecoveryRequestSerializerTest(TestCase):
    @classmethod
    def setUpTestData(cls):
        cls.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )

    def test_deserialization(self):
        data = {
            "email": "test@test.com",
        }
        serializer = AccountRecoveryRequestSerializer(data=data)
        self.assertTrue(serializer.is_valid(), serializer.errors)
        self.assertEqual(serializer.data["email"], "test@test.com")

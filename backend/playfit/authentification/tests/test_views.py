from django.test import TestCase
from rest_framework import status
from rest_framework.test import APITestCase
from rest_framework.authtoken.models import Token
from authentification.models import CustomUser
from authentification.views import ResetPasswordView, AccountRecoveryView

class RegisterViewTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.url = "/api/auth/register/"

    def test_register(self):
        data = {
            'email': 'test2@test.com',
            'username': 'test2',
            'password': 'test12345678910',
            'date_of_birth': '1990-01-01',
            'height': 180,
            'weight': 80,
            'terms_and_conditions': True,
            'privacy_policy': True,
            'marketing': False,
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(CustomUser.objects.count(), 2)

    def test_register_with_existing_email(self):
        data = {
            'email': 'test@test.com',
            'username': 'test2',
            'password': 'test12345',
            'date_of_birth': '1990-01-01',
            'height': 180,
            'weight': 80,
            'terms_and_conditions': True,
            'privacy_policy': True,
            'marketing': False,
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(CustomUser.objects.count(), 1)

    def test_register_with_existing_username(self):
        data = {
            'email': 'test2@test.com',
            'username': 'test',
            'password': 'test12345',
            'date_of_birth': '1990-01-01',
            'height': 180,
            'weight': 80,
            'terms_and_conditions': True,
            'privacy_policy': True,
            'marketing': False,
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(CustomUser.objects.count(), 1)

    def test_register_password_too_common(self):
        data = {
            'email': 'test2@test.com',
            'username': 'test2',
            'password': 'password',
            'date_of_birth': '1990-01-01',
            'height': 180,
            'weight': 80,
            'terms_and_conditions': True,
            'privacy_policy': True,
            'marketing': False,
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(CustomUser.objects.count(), 1)

    def test_register_password_too_short(self):
        data = {
            'email': 'test2@test.com',
            'username': 'test2',
            'password': 'yes',
            'date_of_birth': '1990-01-01',
            'height': 180,
            'weight': 80,
            'terms_and_conditions': True,
            'privacy_policy': True,
            'marketing': False,
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(CustomUser.objects.count(), 1)

    def test_register_password_too_similar_to_username(self):
        data = {
            'email': 'test2@test.com',
            'username': 'test2',
            'password': 'test2',
            'date_of_birth': '1990-01-01',
            'height': 180,
            'weight': 80,
            'terms_and_conditions': True,
            'privacy_policy': True,
            'marketing': False,
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(CustomUser.objects.count(), 1)

    def test_register_with_invalid_date_of_birth(self):
        data = {
            'email': 'test2@test.com',
            'username': 'test2',
            'password': 'test12345',
            'date_of_birth': 'invalid',
            'height': 180,
            'weight': 80,
            'terms_and_conditions': True,
            'privacy_policy': True,
            'marketing': False,
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(CustomUser.objects.count(), 1)

class LoginViewTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.url = "/api/auth/login/"

    def test_login(self):
        data = {
            'username': 'test',
            'password': 'test12345'
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)

    def test_invalid_login(self):
        data = {
            'username': 'test',
            'password': 'invalid'
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_login_with_email(self):
        data = {
            'email': 'test@test.com',
            'password': 'test12345'
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)

    def test_invalid_login_with_email(self):
        data = {
            'email': 'test@invalid.com',
            'password': 'test12345'
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

class LogoutViewTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.url = "/api/auth/logout/"

    def test_logout(self):
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(Token.objects.count(), 0)

    def test_invalid_logout(self):
        response = self.client.post(self.url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(Token.objects.count(), 0)

class UserViewTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.url = "/api/auth/get_my_data/"
        self.update_url = "/api/auth/update_my_data/"
        self.delete_url = "/api/auth/delete_my_data/"

    def test_get_my_data(self):
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["email"], "test@test.com")
        self.assertEqual(response.data["username"], "test")
        self.assertEqual(response.data["date_of_birth"], "1990-01-01")
        self.assertEqual(response.data["height"], "180.00")
        self.assertEqual(response.data["weight"], "80.00")

    def test_update_my_data(self):
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        data = {
            'username': 'test2',
        }
        response = self.client.patch(self.update_url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["username"], "test2")

    def test_delete_my_data(self):
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        response = self.client.delete(self.delete_url, data={'confirm': True}, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK, response.data)        

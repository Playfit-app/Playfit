from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from rest_framework.authtoken.models import Token
from .models import CustomUser

class AuthentificationTests(APITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test123",
            first_name="Test",
            last_name="User",
            date_of_birth="1990-01-01",
            height=180,
            weight=80
        )

    def test_register(self):
        url = reverse('register')
        data = {
            'email': 'test2@test.com',
            'username': 'test2',
            'password': 'test123',
            'first_name': 'Test',
            'last_name': 'User',
            'date_of_birth': '1990-01-01',
            'height': 180,
            'weight': 80
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(CustomUser.objects.count(), 2)

    def test_invalid_register(self):
        url = reverse('register')
        data = {
            'email': 'invalid@test.com',
            'username': 'invalid',
            'first_name': 'Invalid',
            'last_name': 'User',
            'date_of_birth': '1990-01-01',
            'height': 180,
            'weight': 80
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(CustomUser.objects.count(), 1)

    def test_login(self):
        url = reverse('login')
        data = {
            'username': 'test',
            'password': 'test123'
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)

    def test_invalid_login(self):
        url = reverse('login')
        data = {
            'username': 'test',
            'password': 'invalid'
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_login_with_email(self):
        url = reverse('login')
        data = {
            'email': 'test@test.com',
            'password': 'test123'
        }
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('token', response.data)

    def test_logout(self):
        url = reverse('logout')
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        response = self.client.post(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(Token.objects.count(), 0)

    def test_invalid_logout(self):
        url = reverse('logout')
        response = self.client.post(url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        self.assertEqual(Token.objects.count(), 0)

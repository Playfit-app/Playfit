import datetime
from rest_framework import status
from rest_framework.test import APIClient, APIRequestFactory
from rest_framework.authtoken.models import Token
from unittest.mock import patch, MagicMock
from django.utils import timezone as Timezone
from authentification.models import CustomUser, GameAchievement, UserAchievement, UserProgress
from authentification.views import GoogleOAuthLoginView
from authentification.utils import generate_uid_from_id
from social.models import (
    City,
    Country,
    Continent,
    BaseCharacter,
    WorldPosition,
    Customization,
    Follow,
    MountainDecorationImage,
)
from utilities.images import create_test_image
from utilities.expiring_password_reset_token import ExpiringPasswordResetTokenGenerator
from tests.base import BaseAPITestCase

class RegisterViewTests(BaseAPITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.continent = Continent.objects.create(name="Europe")
        self.country = Country.objects.create(name="France", continent=self.continent)
        self.city = City.objects.create(name="Paris", country=self.country, order=1)
        BaseCharacter.objects.create(
            name="character_image",
            image=create_test_image(),
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
            'character_image': "character_image",
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
            'character_image': "character_image",
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
            'character_image': "character_image",
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
            'character_image': "character_image",
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
            'character_image': "character_image",
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
            'character_image': "character_image",
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
            'character_image': "character_image",
        }
        response = self.client.post(self.url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(CustomUser.objects.count(), 1)

class LoginViewTests(BaseAPITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        self.continent = Continent.objects.create(name="Europe")
        self.country = Country.objects.create(name="France", continent=self.continent)
        self.city = City.objects.create(name="Paris", country=self.country, order=1)
        WorldPosition.objects.create(
            user=self.user,
            city=self.city,
            city_level=1,
        )
        self.base_character = BaseCharacter.objects.create(
            name="character_image",
            image=create_test_image(),
        )
        Customization.objects.create(
            user=self.user,
            base_character=self.base_character,
        )
        UserProgress.objects.create(
            user=self.user,
            longest_streak=0,
            current_streak=0,
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

class LogoutViewTests(BaseAPITestCase):
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

class GoogleOAuthLoginViewTests(BaseAPITestCase):
    def setUp(self):
        self.factory = APIRequestFactory()
        self.view = GoogleOAuthLoginView.as_view()
        self.url = "/api/auth/google/"  # Not used by the view, but nice to have
        # Common mock user_data
        self.email = "jane@example.com"
        self.name = "Jane Doe"
        self.user_data = {"email": self.email, "name": self.name}

    def _post(self, payload):
        request = self.factory.post(self.url, payload, format="json")
        return self.view(request)

    # ---------- helpers to patch the social backend & birthdate ----------
    def _patch_backend_ok(self, user_data=None):
        """Patch load_strategy + GoogleOAuth2 to return expected values."""
        if user_data is None:
            user_data = self.user_data

        load_strategy_p = patch("authentification.views.load_strategy", return_value=MagicMock())
        backend_instance = MagicMock()
        backend_instance.do_auth.return_value = None
        backend_instance.user_data.return_value = user_data
        google_backend_p = patch("authentification.views.GoogleOAuth2", return_value=backend_instance)

        return load_strategy_p, google_backend_p, backend_instance

    # ---------- test cases ----------
    def test_missing_token_returns_400(self):
        resp = self._post({})
        self.assertEqual(resp.status_code, 400)
        self.assertIn("No token provided", resp.data.get("message", ""))

    def test_invalid_token_raises_authforbidden_returns_400(self):
        # Simulate social-auth raising AuthForbidden during get_user_data
        with patch("authentification.views.load_strategy", return_value=MagicMock()), \
             patch("authentification.views.GoogleOAuth2", side_effect=__import__("social_core.exceptions").exceptions.AuthForbidden("google")):
            resp = self._post({"token": "bad-token"})
        self.assertEqual(resp.status_code, 400)
        self.assertIn("Invalid token", resp.data.get("message", ""))

    def test_token_without_email_returns_400(self):
        load_strategy_p, google_backend_p, _ = self._patch_backend_ok(user_data={})
        with load_strategy_p, google_backend_p:
            resp = self._post({"token": "ok-token"})
        self.assertEqual(resp.status_code, 400)
        self.assertIn("Invalid token", resp.data.get("message", ""))

    def test_birthdate_missing_returns_400(self):
        load_strategy_p, google_backend_p, _ = self._patch_backend_ok()
        with load_strategy_p, google_backend_p, \
             patch("authentification.views.get_user_birthdate", return_value=None):
            resp = self._post({"token": "ok-token"})

        self.assertEqual(resp.status_code, 400)
        self.assertIn("Aucune date de naissance", resp.data.get("message", ""))

class UserViewTests(BaseAPITestCase):
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

class ResetPasswordRequestViewTests(BaseAPITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        
        # Create another user for testing
        self.other_user = CustomUser.objects.create_user(
            email="other@test.com",
            username="other",
            password="test12345",
            date_of_birth="1990-01-01",
            height=175,
            weight=75,
        )
        
        self.url = "/api/auth/reset_password_request/"
        self.client = APIClient()

    @patch('authentification.views.send_mail')
    def test_reset_password_request_authenticated_user(self, mock_send_mail):
        # When user is authenticated, use their email directly
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        
        response = self.client.post(self.url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['message'], 'Password reset email sent')
        
        # Verify email was sent
        mock_send_mail.assert_called_once()
        call_args = mock_send_mail.call_args
        self.assertEqual(call_args[1]['subject'], "Réinitialisation du mot de passe")
        self.assertEqual(call_args[1]['recipient_list'], [self.user.email])
        self.assertEqual(call_args[1]['from_email'], "playfit.helper@gmail.com")

    # @patch('authentification.views.send_mail')
    # def test_reset_password_request_unauthenticated_with_email(self, mock_send_mail):
    #     # When user is not authenticated, use email from POST data
    #     data = {
    #         'email': self.user.email
    #     }
        
    #     response = self.client.post(self.url, data)
        
    #     self.assertEqual(response.status_code, status.HTTP_200_OK)
    #     self.assertEqual(response.data['message'], 'Password reset email sent')
        
    #     # Verify email was sent
    #     mock_send_mail.assert_called_once()
    #     call_args = mock_send_mail.call_args
    #     self.assertEqual(call_args[1]['subject'], "Réinitialisation du mot de passe")
    #     self.assertEqual(call_args[1]['recipient_list'], [self.user.email])

    # def test_reset_password_request_unauthenticated_no_email(self):
    #     # When user is not authenticated and no email provided
    #     response = self.client.post(self.url)
        
    #     self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    #     self.assertEqual(response.data['error'], 'Email is required')

    # def test_reset_password_request_unauthenticated_empty_email(self):
    #     # When user is not authenticated and empty email provided
    #     data = {
    #         'email': ''
    #     }
        
    #     response = self.client.post(self.url, data)
        
    #     self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    #     self.assertEqual(response.data['error'], 'Email is required')

    # def test_reset_password_request_nonexistent_email(self):
    #     # When email doesn't exist in system
    #     data = {
    #         'email': 'nonexistent@test.com'
    #     }
        
    #     response = self.client.post(self.url, data)
        
    #     self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    #     self.assertEqual(response.data['error'], 'No user found with this email')

    # @patch('authentification.views.send_mail')
    # def test_reset_password_request_generates_correct_link(self, mock_send_mail):
    #     data = {
    #         'email': self.user.email
    #     }
        
    #     response = self.client.post(self.url, data)
        
    #     self.assertEqual(response.status_code, status.HTTP_200_OK)
        
    #     # Verify the reset link contains uid and token
    #     call_args = mock_send_mail.call_args
    #     html_message = call_args[1]['html_message']
    #     self.assertIn('uid=', html_message)
    #     self.assertIn('token=', html_message)
    #     self.assertIn('/api/auth/reset_password', html_message)

    # @patch('authentification.views.send_mail', side_effect=Exception("Email service error"))
    # def test_reset_password_request_email_failure(self, mock_send_mail):
    #     # Test that email sending failures are handled gracefully
    #     data = {
    #         'email': self.user.email
    #     }
        
    #     # The view doesn't handle email exceptions, so it should raise
    #     with self.assertRaises(Exception):
    #         self.client.post(self.url, data)

    # @patch('authentification.views.send_mail')
    # def test_reset_password_request_email_context(self, mock_send_mail):
    #     # Test that the email template receives correct context
    #     data = {
    #         'email': self.user.email
    #     }
        
    #     response = self.client.post(self.url, data)
        
    #     self.assertEqual(response.status_code, status.HTTP_200_OK)
        
    #     # Verify template context includes user and reset_link
    #     call_args = mock_send_mail.call_args
    #     html_message = call_args[1]['html_message']
    #     # The rendered template should contain the user's information
    #     self.assertIn(self.user.username, html_message)

    # def test_reset_password_request_with_json_data(self):
    #     # Test with JSON data instead of form data
    #     data = {
    #         'email': self.user.email
    #     }
        
    #     with patch('authentification.views.send_mail') as mock_send_mail:
    #         response = self.client.post(self.url, data, format='json')
            
    #         self.assertEqual(response.status_code, status.HTTP_200_OK)
    #         self.assertEqual(response.data['message'], 'Password reset email sent')
    #         mock_send_mail.assert_called_once()

    # def test_reset_password_request_case_sensitive_email(self):
    #     # Test that email lookup works regardless of case
    #     data = {
    #         'email': self.user.email.upper()
    #     }
        
    #     # This should fail because the hash function is case-sensitive
    #     response = self.client.post(self.url, data)
        
    #     self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    #     self.assertEqual(response.data['error'], 'No user found with this email')

class ResetPasswordViewTests(BaseAPITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        
        self.token_generator = ExpiringPasswordResetTokenGenerator()
        self.valid_token = self.token_generator.make_signed_token(self.user)
        self.valid_uid = generate_uid_from_id(self.user.id)
        
        self.url_get = f"/api/auth/reset_password/?uid={self.valid_uid}&token={self.valid_token}"
        self.url_post = "/api/auth/reset_password/"
        self.client = APIClient()

    def test_get_reset_password_valid_link(self):
        response = self.client.get(self.url_get)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertContains(response, self.valid_uid)
        self.assertContains(response, self.valid_token)

    def test_get_reset_password_missing_uid(self):
        url = f"/api/auth/reset_password/?token={self.valid_token}"
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Lien non valide", status_code=400)

    def test_get_reset_password_missing_token(self):
        url = f"/api/auth/reset_password/?uid={self.valid_uid}"
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Lien non valide", status_code=400)

    # def test_get_reset_password_invalid_uid(self):
    #     url = f"/api/auth/reset_password/?uid=invalid&token={self.valid_token}"
    #     response = self.client.get(url)
        
    #     self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    #     self.assertContains(response, "Lien non valide", status_code=400)

    def test_get_reset_password_nonexistent_user(self):
        fake_uid = generate_uid_from_id(99999)
        url = f"/api/auth/reset_password/?uid={fake_uid}&token={self.valid_token}"
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Lien non valide", status_code=400)

    def test_get_reset_password_expired_token(self):
        invalid_token = "invalid_token"
        url = f"/api/auth/reset_password/?uid={self.valid_uid}&token={invalid_token}"
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Le lien a expiré", status_code=400)

    def test_post_reset_password_successful(self):
        data = {
            'uid': self.valid_uid,
            'token': self.valid_token,
            'password': 'newpassword123456',
            'confirm_password': 'newpassword123456',
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertContains(response, "Mot de passe réinitialisé")
        
        # Verify password was actually changed
        self.user.refresh_from_db()
        self.assertTrue(self.user.check_password('newpassword123456'))

    def test_post_reset_password_missing_uid(self):
        data = {
            'token': self.valid_token,
            'password': 'newpassword123456',
            'confirm_password': 'newpassword123456',
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Données manquantes", status_code=400)

    def test_post_reset_password_missing_token(self):
        data = {
            'uid': self.valid_uid,
            'password': 'newpassword123456',
            'confirm_password': 'newpassword123456',
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Données manquantes", status_code=400)

    def test_post_reset_password_missing_password(self):
        data = {
            'uid': self.valid_uid,
            'token': self.valid_token,
            'confirm_password': 'newpassword123456',
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Données manquantes", status_code=400)

    # def test_post_reset_password_invalid_uid(self):
    #     data = {
    #         'uid': 'invalid',
    #         'token': self.valid_token,
    #         'password': 'newpassword123456',
    #         'confirm_password': 'newpassword123456',
    #     }
        
    #     response = self.client.post(self.url_post, data)
        
    #     self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    #     self.assertContains(response, "Données manquantes", status_code=400)

    def test_post_reset_password_nonexistent_user(self):
        fake_uid = generate_uid_from_id(99999)
        data = {
            'uid': fake_uid,
            'token': self.valid_token,
            'password': 'newpassword123456',
            'confirm_password': 'newpassword123456',
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Données manquantes", status_code=400)

    def test_post_reset_password_expired_token(self):
        data = {
            'uid': self.valid_uid,
            'token': 'invalid_token',
            'password': 'newpassword123456',
            'confirm_password': 'newpassword123456',
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Le lien a expiré", status_code=400)

    def test_post_reset_password_password_mismatch(self):
        data = {
            'uid': self.valid_uid,
            'token': self.valid_token,
            'password': 'newpassword123456',
            'confirm_password': 'differentpassword',
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Les mots de passe ne correspondent pas", status_code=400)

    def test_post_reset_password_weak_password(self):
        data = {
            'uid': self.valid_uid,
            'token': self.valid_token,
            'password': 'weak',
            'confirm_password': 'weak',
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        # Should contain password validation error
        self.assertIn("error", response.context)

    def test_post_reset_password_missing_confirm_password(self):
        # Test case where confirm_password is None but password validation still runs
        data = {
            'uid': self.valid_uid,
            'token': self.valid_token,
            'password': 'newpassword123456',
            # confirm_password is missing, so it will be None
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Les mots de passe ne correspondent pas", status_code=400)

class AccountRecoveryRequestViewTests(BaseAPITestCase):
    def setUp(self):
        # Create an inactive user for account recovery
        self.inactive_user = CustomUser.objects.create_user(
            email="inactive@test.com",
            username="inactive",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            is_active=False  # Inactive user for recovery
        )
        
        # Create an active user to test that recovery doesn't work for active users
        self.active_user = CustomUser.objects.create_user(
            email="active@test.com",
            username="active",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            is_active=True
        )
        
        self.url = "/api/auth/account_recovery_request/"
        self.client = APIClient()

    @patch('authentification.views.send_mail')
    def test_account_recovery_request_successful(self, mock_send_mail):
        data = {
            'email': self.inactive_user.email
        }
        
        response = self.client.post(self.url, data)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['message'], 'Account recovery email sent')
        
        # Verify email was sent
        mock_send_mail.assert_called_once()
        call_args = mock_send_mail.call_args
        self.assertEqual(call_args[1]['subject'], "Récupération de compte")
        self.assertEqual(call_args[1]['recipient_list'], [self.inactive_user.email])
        self.assertEqual(call_args[1]['from_email'], "playfit.helper@gmail.com")

    def test_account_recovery_request_no_user_found(self):
        data = {
            'email': 'nonexistent@test.com'
        }
        
        response = self.client.post(self.url, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('email', response.data)

    def test_account_recovery_request_active_user(self):
        # Should not work for active users
        data = {
            'email': self.active_user.email
        }
        
        response = self.client.post(self.url, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.data['error'], 'No user found with this email')

    def test_account_recovery_request_missing_email(self):
        data = {}
        
        response = self.client.post(self.url, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('email', response.data)

    def test_account_recovery_request_empty_email(self):
        data = {
            'email': ''
        }
        
        response = self.client.post(self.url, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('email', response.data)

    def test_account_recovery_request_invalid_email_format(self):
        data = {
            'email': 'invalid-email'
        }
        
        response = self.client.post(self.url, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('email', response.data)

    @patch('authentification.views.send_mail')
    def test_account_recovery_request_generates_correct_link(self, mock_send_mail):
        data = {
            'email': self.inactive_user.email
        }
        
        response = self.client.post(self.url, data)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify the reset link contains uid and token
        call_args = mock_send_mail.call_args
        html_message = call_args[1]['html_message']
        self.assertIn('uid=', html_message)
        self.assertIn('token=', html_message)
        self.assertIn('/api/auth/account_recovery', html_message)

    @patch('authentification.views.send_mail', side_effect=Exception("Email service error"))
    def test_account_recovery_request_email_failure(self, mock_send_mail):
        # Test that email sending failures are handled gracefully
        data = {
            'email': self.inactive_user.email
        }
        
        # The view doesn't handle email exceptions, so it should raise
        with self.assertRaises(Exception):
            self.client.post(self.url, data)

class AccountRecoveryViewTests(BaseAPITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            is_active=False  # Inactive user for account recovery
        )
        
        # Create another active user for comparison
        self.active_user = CustomUser.objects.create_user(
            email="active@test.com",
            username="active",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            is_active=True
        )
        
        self.token_generator = ExpiringPasswordResetTokenGenerator()
        self.valid_token = self.token_generator.make_email_signed_token(self.user, self.user.email)
        self.valid_uid = generate_uid_from_id(self.user.id)
        
        self.url_get = f"/api/auth/account_recovery/?uid={self.valid_uid}&token={self.valid_token}"
        self.url_post = "/api/auth/account_recovery/"
        self.client = APIClient()

    def test_get_account_recovery_valid_link(self):
        response = self.client.get(self.url_get)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        # self.assertContains(response, "account_recovery.html")
        self.assertContains(response, self.valid_uid)
        self.assertContains(response, self.valid_token)
        self.assertContains(response, self.user.email)

    def test_get_account_recovery_missing_uid(self):
        url = f"/api/auth/account_recovery/?token={self.valid_token}"
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Lien non valide", status_code=400)

    def test_get_account_recovery_missing_token(self):
        url = f"/api/auth/account_recovery/?uid={self.valid_uid}"
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Lien non valide", status_code=400)

    # def test_get_account_recovery_invalid_uid(self):
    #     url = f"/api/auth/account_recovery/?uid=invalid&token={self.valid_token}"
    #     response = self.client.get(url)
        
    #     self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    #     self.assertContains(response, "Lien non valide", status_code=400)

    def test_get_account_recovery_nonexistent_user(self):
        fake_uid = generate_uid_from_id(99999)
        url = f"/api/auth/account_recovery/?uid={fake_uid}&token={self.valid_token}"
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Lien non valide", status_code=400)

    def test_get_account_recovery_expired_token(self):
        # Create an invalid token
        invalid_token = "invalid_token"
        url = f"/api/auth/account_recovery/?uid={self.valid_uid}&token={invalid_token}"
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Lien expiré", status_code=400)

    def test_post_account_recovery_successful(self):
        data = {
            'uid': self.valid_uid,
            'token': self.valid_token,
            'email': self.user.email,
            'username': 'newusername',
            'password': 'newpassword123456',
            'confirm_password': 'newpassword123456',
            'date_of_birth': '1990-01-01',
            'height': '175',
            'weight': '70'
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertContains(response, "Account recovered")
        
        # Verify user was updated
        self.user.refresh_from_db()
        self.assertEqual(self.user.username, 'newusername')
        self.assertEqual(self.user.height, 175)
        self.assertEqual(self.user.weight, 70)
        self.assertTrue(self.user.is_active)
        self.assertEqual(self.user.registration_method, 'email')

    def test_post_account_recovery_missing_data(self):
        data = {
            'uid': self.valid_uid,
            'token': self.valid_token,
            'email': self.user.email,
            # Missing username, password, etc.
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Donnée(s) manquante(s)", status_code=400)

    # def test_post_account_recovery_invalid_uid(self):
    #     data = {
    #         'uid': 'invalid',
    #         'token': self.valid_token,
    #         'email': self.user.email,
    #         'username': 'newusername',
    #         'password': 'newpassword123456',
    #         'confirm_password': 'newpassword123456',
    #         'date_of_birth': '1990-01-01',
    #         'height': '175',
    #         'weight': '70'
    #     }
        
    #     response = self.client.post(self.url_post, data)
        
    #     self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    #     self.assertContains(response, "Lien non valide", status_code=400)

    def test_post_account_recovery_expired_token(self):
        data = {
            'uid': self.valid_uid,
            'token': 'invalid_token',
            'email': self.user.email,
            'username': 'newusername',
            'password': 'newpassword123456',
            'confirm_password': 'newpassword123456',
            'date_of_birth': '1990-01-01',
            'height': '175',
            'weight': '70'
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Le lien a expiré", status_code=400)

    def test_post_account_recovery_password_mismatch(self):
        data = {
            'uid': self.valid_uid,
            'token': self.valid_token,
            'email': self.user.email,
            'username': 'newusername',
            'password': 'newpassword123456',
            'confirm_password': 'differentpassword',
            'date_of_birth': '1990-01-01',
            'height': '175',
            'weight': '70'
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Les mots de passe ne correspondent pas", status_code=400)

    def test_post_account_recovery_weak_password(self):
        data = {
            'uid': self.valid_uid,
            'token': self.valid_token,
            'email': self.user.email,
            'username': 'newusername',
            'password': 'weak',
            'confirm_password': 'weak',
            'date_of_birth': '1990-01-01',
            'height': '175',
            'weight': '70'
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        # Should contain password validation error

    def test_post_account_recovery_invalid_date_format(self):
        data = {
            'uid': self.valid_uid,
            'token': self.valid_token,
            'email': self.user.email,
            'username': 'newusername',
            'password': 'newpassword123456',
            'confirm_password': 'newpassword123456',
            'date_of_birth': 'invalid-date',
            'height': '175',
            'weight': '70'
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "Format de la date invalide", status_code=400)

    def test_post_account_recovery_underage_user(self):
        # Create a date that makes user under 18
        recent_date = (datetime.date.today() - datetime.timedelta(days=365*17)).isoformat()
        
        data = {
            'uid': self.valid_uid,
            'token': self.valid_token,
            'email': self.user.email,
            'username': 'newusername',
            'password': 'newpassword123456',
            'confirm_password': 'newpassword123456',
            'date_of_birth': recent_date,
            'height': '175',
            'weight': '70'
        }
        
        response = self.client.post(self.url_post, data)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertContains(response, "You must be at least 18 years old to register", status_code=400)

class UserAchievementViewTests(BaseAPITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        
        # Create test achievements
        self.achievement1 = GameAchievement.objects.create(
            name="First Achievement",
            description="Your first achievement",
            type="level",
            target=1,
            xp_reward=50,
            created_at=Timezone.now(),
        )
        
        self.achievement2 = GameAchievement.objects.create(
            name="Second Achievement", 
            description="Your second achievement",
            type="workout",
            target=5,
            xp_reward=100,
            created_at=Timezone.now(),
        )
        
        # Create user achievements
        self.user_achievement1 = UserAchievement.objects.create(
            user=self.user,
            achievement=self.achievement1,
        )
        
        self.user_achievement2 = UserAchievement.objects.create(
            user=self.user,
            achievement=self.achievement2,
        )
        
        self.url = "/api/auth/user-achievements/"
        self.client = APIClient()

    def test_get_user_achievements_authenticated(self):
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)
        
        # Check that achievements are properly serialized
        achievement_names = [achievement['name'] for achievement in response.data]
        self.assertIn("First Achievement", achievement_names)
        self.assertIn("Second Achievement", achievement_names)

    def test_get_user_achievements_unauthenticated(self):
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_get_user_achievements_empty_list(self):
        # Create a user with no achievements
        user_no_achievements = CustomUser.objects.create_user(
            email="empty@test.com",
            username="empty",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        
        token = Token.objects.create(user=user_no_achievements)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 0)
        self.assertEqual(response.data, [])

    def test_get_user_achievements_only_returns_current_user_achievements(self):
        # Create another user with different achievements
        other_user = CustomUser.objects.create_user(
            email="other@test.com",
            username="other",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        
        other_achievement = GameAchievement.objects.create(
            name="Other Achievement",
            description="Other user's achievement",
            type="level",
            target=2,
            xp_reward=75,
            created_at=Timezone.now(),
        )
        
        UserAchievement.objects.create(
            user=other_user,
            achievement=other_achievement,
        )
        
        # Authenticate as the first user
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        response = self.client.get(self.url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(response.data), 2)  # Only the original user's achievements
        
        # Verify the other user's achievement is not included
        achievement_names = [achievement['name'] for achievement in response.data]
        self.assertNotIn("Other Achievement", achievement_names)
        self.assertIn("First Achievement", achievement_names)
        self.assertIn("Second Achievement", achievement_names)

class ProfileViewTests(BaseAPITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
            first_name="Test"
        )
        
        # Create another user for testing non-"me" profiles
        self.other_user = CustomUser.objects.create_user(
            email="other@test.com",
            username="other",
            password="test12345",
            date_of_birth="1990-01-01",
            height=175,
            weight=75,
            first_name="Other"
        )
        
        # Create continent, country, city for world position
        self.continent = Continent.objects.create(name="Europe")
        self.country = Country.objects.create(name="France", continent=self.continent)
        self.city = City.objects.create(name="Paris", country=self.country, order=1)
        
        # Create base character
        self.base_character = BaseCharacter.objects.create(
            name="character_image",
            image=create_test_image(),
        )
        
        # Create user progress
        UserProgress.objects.create(
            user=self.user,
            current_streak=5,
            longest_streak=10,
            cities_finished=3,
            level=2,
            xp=150
        )
        
        UserProgress.objects.create(
            user=self.other_user,
            current_streak=3,
            longest_streak=8,
            cities_finished=2,
            level=1,
            xp=80
        )
        
        # Create customization
        Customization.objects.create(
            user=self.user,
            base_character=self.base_character,
        )
        
        Customization.objects.create(
            user=self.other_user,
            base_character=self.base_character,
        )
        
        # Create achievement for testing
        self.achievement = GameAchievement.objects.create(
            name="Test Achievement",
            description="Test description",
            type="level",
            target=1,
            xp_reward=50,
        )
        
        UserAchievement.objects.create(
            user=self.user,
            achievement=self.achievement,
        )
        
        # Create mountain decoration
        MountainDecorationImage.objects.create(
            image=create_test_image(),
        )
        
        self.url_me = "/api/auth/profile/me/"
        self.url_other = f"/api/auth/profile/{self.other_user.id}/"
        self.url_invalid = "/api/auth/profile/invalid/"
        self.client = APIClient()

    def test_get_my_profile(self):
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        response = self.client.get(self.url_me)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["user"]["id"], self.user.id)
        self.assertEqual(response.data["user"]["username"], "test")
        self.assertEqual(response.data["user"]["first_name"], "Test")
        self.assertIn("achievements", response.data)
        self.assertIn("progress", response.data)
        self.assertIn("customization", response.data)
        self.assertIn("following", response.data)
        self.assertIn("followers", response.data)
        self.assertIn("decorations", response.data)
        self.assertIn("last_7_days", response.data)
        self.assertNotIn("is_following", response.data)  # Should not be present for "me"
        
        # Check progress data
        self.assertEqual(response.data["progress"]["current_streak"], 5)
        self.assertEqual(response.data["progress"]["cities_finished"], 3)
        self.assertEqual(response.data["progress"]["level"], 2)
        self.assertEqual(response.data["progress"]["current_xp"], 150)
        
        # Check last 7 days structure
        self.assertIn("dates", response.data["last_7_days"])
        self.assertIn("repetitions", response.data["last_7_days"])
        self.assertEqual(len(response.data["last_7_days"]["dates"]), 7)
        self.assertEqual(len(response.data["last_7_days"]["repetitions"]), 7)

    def test_get_other_user_profile(self):
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        response = self.client.get(self.url_other)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["user"]["id"], self.other_user.id)
        self.assertEqual(response.data["user"]["username"], "other")
        self.assertEqual(response.data["user"]["first_name"], "Other")
        self.assertIn("is_following", response.data)  # Should be present for other users
        self.assertEqual(response.data["is_following"], False)  # Not following initially

    def test_get_other_user_profile_when_following(self):
        # Create follow relationship
        Follow.objects.create(follower=self.user, following=self.other_user)
        
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        response = self.client.get(self.url_other)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data["is_following"], True)

    def test_get_profile_invalid_user_id(self):
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        response = self.client.get(self.url_invalid)
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn("Invalid user ID format", response.data["error"])

    def test_get_profile_nonexistent_user(self):
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        nonexistent_url = "/api/auth/profile/99999/"
        response = self.client.get(nonexistent_url)
        
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)

    def test_get_profile_unauthenticated(self):
        response = self.client.get(self.url_me)
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

class GetMyProgressTests(BaseAPITestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="test",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )
        UserProgress.objects.create(
            user=self.user,
            current_streak=5,
            longest_streak=10,
            cities_finished=3,
        )
        self.url = "/api/auth/get_my_progress/"
        self.client = APIClient()

    def test_get_my_progress(self):
        token = Token.objects.create(user=self.user)
        self.client.credentials(HTTP_AUTHORIZATION='Token ' + token.key)
        response = self.client.get(self.url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn("current_streak", response.data)
        self.assertIn("cities_finished", response.data)
        self.assertIn("level", response.data)
        self.assertIn("current_xp", response.data)
        self.assertIn("required_xp", response.data)

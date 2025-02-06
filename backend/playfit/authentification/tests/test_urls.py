from django.test import SimpleTestCase
from django.urls import resolve, reverse
from authentification.views import RegisterView, LoginView, LogoutView, UserView, GoogleOAuthLoginView,\
                                    ResetPasswordRequestView, ResetPasswordView, AccountRecoveryRequestView, AccountRecoveryView

class TestUrls(SimpleTestCase):
    def test_register_url_resolves(self):
        url = reverse('register')
        self.assertEqual(resolve(url).func.view_class, RegisterView)

    def test_login_url_resolves(self):
        url = reverse('login')
        self.assertEqual(resolve(url).func.view_class, LoginView)

    def test_logout_url_resolves(self):
        url = reverse('logout')
        self.assertEqual(resolve(url).func.view_class, LogoutView)

    def test_get_my_data_url_resolves(self):
        url = reverse('get_my_data')
        self.assertEqual(resolve(url).func.view_class, UserView)

    def test_update_my_data_url_resolves(self):
        url = reverse('update_my_data')
        self.assertEqual(resolve(url).func.view_class, UserView)

    def test_delete_my_data_url_resolves(self):
        url = reverse('delete_my_data')
        self.assertEqual(resolve(url).func.view_class, UserView)

    def test_reset_password_request_url_resolves(self):
        url = reverse('reset_password_request')
        self.assertEqual(resolve(url).func.view_class, ResetPasswordRequestView)

    def test_reset_password_url_resolves(self):
        url = reverse('reset_password')
        self.assertEqual(resolve(url).func.view_class, ResetPasswordView)

    def test_account_recovery_request_url_resolves(self):
        url = reverse('account_recovery_request')
        self.assertEqual(resolve(url).func.view_class, AccountRecoveryRequestView)

    def test_account_recovery_url_resolves(self):
        url = reverse('account_recovery')
        self.assertEqual(resolve(url).func.view_class, AccountRecoveryView)

    def test_google_login_url_resolves(self):
        url = reverse('google-login')
        self.assertEqual(resolve(url).func.view_class, GoogleOAuthLoginView)

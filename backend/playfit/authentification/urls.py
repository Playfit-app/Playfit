from django.urls import path, include
from .views import RegisterView, LoginView, LogoutView, UserView, GoogleOAuthLoginView, ResetPasswordRequestView, ResetPasswordView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('get_my_data/', UserView.as_view(), name='get_my_data'),
    path('update_my_data/', UserView.as_view(), name='update_my_data'),
    path('delete_my_data/', UserView.as_view(), name='delete_my_data'),
    path('reset_password_request/', ResetPasswordRequestView.as_view(), name='reset_password_request'),
    path('reset_password/', ResetPasswordView.as_view(), name='reset_password'),
    path('', include("social_django.urls", namespace="social")),
    path('google-login/', GoogleOAuthLoginView.as_view(), name='google-login'),
]

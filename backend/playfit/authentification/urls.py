from django.urls import path, include
from .views import (
    RegisterView,
    LoginView,
    LogoutView,
    UserView,
    GoogleOAuthLoginView,
    ResetPasswordRequestView,
    ResetPasswordView,
    AccountRecoveryRequestView,
    AccountRecoveryView,
    UserAchievementView,
    ProfileView,
)

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('get_my_data/', UserView.as_view(), name='get_my_data'),
    path('update_my_data/', UserView.as_view(), name='update_my_data'),
    path('delete_my_data/', UserView.as_view(), name='delete_my_data'),
    path('reset_password_request/', ResetPasswordRequestView.as_view(), name='reset_password_request'),
    path('reset_password/', ResetPasswordView.as_view(), name='reset_password'),
    path('account_recovery_request/', AccountRecoveryRequestView.as_view(), name='account_recovery_request'),
    path('account_recovery/', AccountRecoveryView.as_view(), name='account_recovery'),
    path('', include("social_django.urls", namespace="social")),
    path('google-login/', GoogleOAuthLoginView.as_view(), name='google-login'),
    path('user-achievements/', UserAchievementView.as_view(), name='user-achievements'),
    path('profile/', ProfileView.as_view(), name='profile'),
]

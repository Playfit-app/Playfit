from django.urls import path, include
from .views import RegisterView, LoginView, LogoutView, UserView, GoogleOAuthLoginView, PasswordResetRequestView, PasswordResetConfirmView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('get_my_data/', UserView.as_view(), name='get_my_data'),
    path('update_my_data/', UserView.as_view(), name='update_my_data'),
    path('delete_my_data/', UserView.as_view(), name='delete_my_data'),
    path('password_reset/', PasswordResetRequestView.as_view(), name='password_reset'),
    path('password_reset/<uidb64>/<token>/', PasswordResetConfirmView.as_view(), name='password_reset_confirm'),
    path('', include("social_django.urls", namespace="social")),
    path('google-login/', GoogleOAuthLoginView.as_view(), name='google-login'),
]

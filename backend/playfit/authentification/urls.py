from django.urls import path, include
from .views import RegisterView, LoginView, LogoutView, GoogleOAuthLoginView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('', include("social_django.urls", namespace="social")),
    path('google-login/', GoogleOAuthLoginView.as_view(), name='google-login'),
]

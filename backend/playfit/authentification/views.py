from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.authtoken.models import Token
from django.contrib.auth import authenticate, login
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from social_django.utils import load_strategy
from social_core.backends.google import GoogleOAuth2
from social_core.exceptions import AuthForbidden
from utilities.encrypted_fields import hash
from .models import CustomUser
from .serializers import CustomUserSerializer, CustomUserRetrieveSerializer, CustomUserUpdateSerializer, CustomUserDeleteSerializer
from .utils import generate_username_with_number, get_user_birthdate

class RegisterView(APIView):
    permission_classes = [AllowAny]

    @swagger_auto_schema(
        request_body=CustomUserSerializer,
        responses={
            201: openapi.Response("User registered successfully", CustomUserSerializer),
            400: "Invalid data",
        },
        operation_description="Register a new user with username, email, height, weight, date of birth, and password."
    )
    def post(self, request):
        serializer = CustomUserSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            token, _ = Token.objects.get_or_create(user=user)
            return Response({'token': token.key}, status=status.HTTP_201_CREATED)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    permission_classes = [AllowAny]

    @swagger_auto_schema(
        operation_description="User login with username or email and password.",
        responses={
            200: openapi.Response("User logged in successfully"),
            400: "Invalid credentials",
        },
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'username': openapi.Schema(type=openapi.TYPE_STRING),
                'email': openapi.Schema(type=openapi.TYPE_STRING),
                'password': openapi.Schema(type=openapi.TYPE_STRING),
            },
            required=['username', 'password']
        )
    )
    def post(self, request):
        username = request.data.get('username')
        email = request.data.get('email')
        password = request.data.get('password')
        user = authenticate(username=username, password=password)

        if user is None:
            try:
                if not email:
                    raise CustomUser.DoesNotExist
                user = CustomUser.objects.get(email_hash=hash(email))
                user = authenticate(username=user.username, password=password)
            except CustomUser.DoesNotExist:
                return Response({'error': "Invalid credentials"}, status=status.HTTP_400_BAD_REQUEST)

        token, _ = Token.objects.get_or_create(user=user)
        return Response({'token': token.key}, status=status.HTTP_200_OK)

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="User logout.",
        responses={
            200: openapi.Response("User logged out successfully"),
            400: "Invalid credentials",
        }
    )
    def post(self, request):
        try:
            token = Token.objects.get(user=request.user)
            token.delete()
            return Response({'success': "Successfully logged out"}, status=status.HTTP_200_OK)
        except Token.DoesNotExist:
            return Response({'error': "Token not found or already logged out"}, status=status.HTTP_400_BAD_REQUEST)

class GoogleOAuthLoginView(APIView):
    permission_classes = [AllowAny]

    def get_user_data(self, request, token):
        strategy = load_strategy(request)
        backend = GoogleOAuth2(strategy)
        backend.do_auth(token)
        user_data = backend.user_data(token)

        return user_data

    def create_user(self, user_data, birth_date):
        email = user_data.get('email')
        user = CustomUser.objects.create_user(
            email=email,
            email_hash=hash(email),
            username=generate_username_with_number(user_data.get('name') or email.split('@')[0]),
            password=None,
            registration_method='google',
            date_of_birth=birth_date,
            height=250,
            weight=250,
        )
        user.is_active = True
        user.save()

        return user

    def post(self, request):
        token = request.data.get('token')
        if not token:
            return Response({'status': 'error', 'message': 'No token provided'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user_data = self.get_user_data(request, token)
            email = user_data.get('email')

            if not email:
                return Response({'status': 'error', 'message': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)

            try:
                user = CustomUser.objects.get(email_hash=hash(email))
                if user.registration_method in ['google', 'email']:
                    login(request, user)
                    django_token, _ = Token.objects.get_or_create(user=user)
                    return Response({'status': 'success', 'message': 'Logged in using Google', 'token': django_token.key}, status=status.HTTP_200_OK)
                else:
                    return Response({'status': 'error', 'message': 'Cannot log in with email and password'}, status=status.HTTP_400_BAD_REQUEST)
            except CustomUser.DoesNotExist:
                birth_date = get_user_birthdate(token)
                if not birth_date:
                    return Response({'status': 'error', 'message': 'Aucune date de naissance renseignée, impossible de vérifier votre âge'}, status=status.HTTP_400_BAD_REQUEST)

                user = self.create_user(user_data, birth_date)
                login(request, user)
                django_token, _ = Token.objects.get_or_create(user=user)
                return Response({'status': 'success', 'message': 'Account created and logged in', 'token': django_token.key}, status=status.HTTP_200_OK)
        except AuthForbidden:
            return Response({'status': 'error', 'message': 'Invalid token'}, status=status.HTTP_400_BAD_REQUEST)

class UserView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Get user data.",
        responses={
            200: openapi.Response("User data", CustomUserRetrieveSerializer),
        }
    )
    def get(self, request):
        serializer = CustomUserRetrieveSerializer(request.user)
        return Response(serializer.data, status=status.HTTP_200_OK)

    @swagger_auto_schema(
        request_body=CustomUserUpdateSerializer,
        operation_description="Update user data.",
        responses={
            200: openapi.Response("User data updated", CustomUserUpdateSerializer),
            400: "Invalid data",
        }
    )
    def patch(self, request):
        serializer = CustomUserUpdateSerializer(request.user, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    @swagger_auto_schema(
        request_body=CustomUserDeleteSerializer,
        operation_description="Delete (anonymize) the current user's data.",
        responses={
            200: openapi.Response("User data deleted"),
            400: "Invalid data",
        }
    )
    def delete(self, request):
        serializer = CustomUserDeleteSerializer(request.user, data=request.data)
        if serializer.is_valid():
            request.user.anonynimze_user()
            return Response({'message': 'Your data has been anonymized successfully.'}, status=status.HTTP_200_OK)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.generics import ListAPIView, CreateAPIView, DestroyAPIView, get_object_or_404
from django.contrib.auth import get_user_model
from .models import Follow
from .serializers import UserSerializer

User = get_user_model()

class FollowersListView(ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return User.objects.filter(following__follower=user)

class FollowingListView(ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        return User.objects.filter(followers__following=user)

class FollowCreateView(CreateAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        user_to_follow = get_object_or_404(User, id=request.data.get('id'))
        if user == user_to_follow:
            return Response({'detail': 'You cannot follow yourself'}, status=status.HTTP_400_BAD_REQUEST)
        follow = Follow.objects.filter(follower=user, following=user_to_follow)
        if follow.exists():
            return Response({'detail': 'You already follow this user'}, status=status.HTTP_400_BAD_REQUEST)
        Follow.objects.create(follower=user, following=user_to_follow)
        return Response({'detail': 'User followed'}, status=status.HTTP_201_CREATED)

class FollowDeleteView(DestroyAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def delete(self, request, *args, **kwargs):
        user = request.user
        user_to_unfollow = get_object_or_404(User, id=kwargs['id'])
        follow = get_object_or_404(Follow, follower=user, following=user_to_unfollow)
        follow.delete()
        return Response({'detail': 'User unfollowed'}, status=status.HTTP_204_NO_CONTENT)

from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.generics import ListAPIView, CreateAPIView, DestroyAPIView, get_object_or_404
from rest_framework.views import APIView
from authentification.models import CustomUser
from .models import Follow, CustomizationItem, Customization
from .serializers import UserSerializer, CustomizationItemSerializer, CustomizationSerializer

class CustomizationItemListView(ListAPIView):
    serializer_class = CustomizationItemSerializer
    queryset = CustomizationItem.objects.all()
    permission_classes = [IsAuthenticated]

class CustomizationItemByCategoryListView(ListAPIView):
    serializer_class = CustomizationItemSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        category = self.kwargs['category']
        return CustomizationItem.objects.filter(category=category)

class CustomizationUpdateView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request):
        user: CustomUser = request.user
        customization = Customization.objects.get(user=user)
        serializer = CustomizationSerializer(customization, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

class CustomizationView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user: CustomUser = request.user
        customization = Customization.objects.get(user=user)
        serializer = CustomizationSerializer(customization)
        return Response(serializer.data)

class FollowersListView(ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user: CustomUser = self.request.user
        return user.get_followers()

class FollowingListView(ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user: CustomUser = self.request.user
        return user.get_following()

class FollowCreateView(CreateAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        user_to_follow = get_object_or_404(CustomUser, id=request.data.get('id'))
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
        user_to_unfollow = get_object_or_404(CustomUser, id=kwargs['id'])
        follow = get_object_or_404(Follow, follower=user, following=user_to_unfollow)
        follow.delete()
        return Response({'detail': 'User unfollowed'}, status=status.HTTP_204_NO_CONTENT)

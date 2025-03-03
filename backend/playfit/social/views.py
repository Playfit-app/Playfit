from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.generics import (
    ListAPIView,
    CreateAPIView,
    UpdateAPIView,
    DestroyAPIView,
    get_object_or_404,
)
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from authentification.models import CustomUser
from .models import Follow, Post, Like, Comment, Notification
from .serializers import (
    UserSerializer,
    PostSerializer,
    LikeSerializer,
    CommentSerializer,
    NotificationSerializer,
)

def send_notification(user, notification_data):
    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        f"notifications_{user.id}",
        {
            "type": "send_notification",
            "message": {
                "data": notification_data,
            },
        },
    )

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
        user_to_follow = get_object_or_404(CustomUser, id=request.data.get("id"))
        if user == user_to_follow:
            return Response(
                {"detail": "You cannot follow yourself"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        follow = Follow.objects.filter(follower=user, following=user_to_follow)
        if follow.exists():
            return Response(
                {"detail": "You already follow this user"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        Follow.objects.create(follower=user, following=user_to_follow)
        notification = Notification.objects.create(
            user=user_to_follow,
            sender=user,
            notification_type="follow",
        )
        send_notification(user_to_follow, {
            'id': notification.id,
            'sender': user.username,
            'notification_type': notification.notification_type,
            'created_at': notification.created_at,
            'post': None,
            'seen': notification.seen,
        })
        return Response({"detail": "User followed"}, status=status.HTTP_201_CREATED)


class FollowDeleteView(DestroyAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    def delete(self, request, *args, **kwargs):
        user = request.user
        user_to_unfollow = get_object_or_404(CustomUser, id=kwargs["id"])
        follow = get_object_or_404(Follow, follower=user, following=user_to_unfollow)
        follow.delete()
        return Response(
            {"detail": "User unfollowed"}, status=status.HTTP_204_NO_CONTENT
        )


class PostCreateView(CreateAPIView):
    serializer_class = PostSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        serializer = self.get_serializer(data=request.data)

        if serializer.is_valid():
            serializer.save(user=user)
            followers = list(user.get_followers())
            notifications = [
                Notification(
                    user=follower,
                    sender=user,
                    notification_type="post",
                    post=serializer.instance,
                )
                for follower in followers
            ]
            Notification.objects.bulk_create(notifications)
            for follower in followers:
                send_notification(follower, {
                    'id': notifications[followers.index(follower)].id,
                    'sender': user.username,
                    'notification_type': notifications[followers.index(follower)].notification_type,
                    'created_at': notifications[followers.index(follower)].created_at.isoformat(),
                    'post': serializer.instance.id,
                    'seen': notifications[followers.index(follower)].seen,
                })
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class PostListView(ListAPIView):
    serializer_class = PostSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user: CustomUser = self.request.user
        if self.request.query_params.get("profile"):
            return user.posts.all()
        return Post.objects.filter(user__in=user.get_following())

class LikePostView(CreateAPIView):
    serializer_class = LikeSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        post = get_object_or_404(Post, id=request.data.get("post"))
        like = Like.objects.filter(user=user, post=post)
        if like.exists():
            return Response(
                {"detail": "You already liked this post"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        Like.objects.create(user=user, post=post)
        notification = Notification.objects.create(
            user=post.user,
            sender=user,
            notification_type="like",
            post=post,
        )
        send_notification(post.user, {
            'id': notification.id,
            'sender': user.username,
            'notification_type': notification.notification_type,
            'created_at': notification.created_at,
            'post': post.id,
            'seen': notification.seen,
        })
        return Response({"detail": "Post liked"}, status=status.HTTP_201_CREATED)

class UnlikePostView(DestroyAPIView):
    serializer_class = LikeSerializer
    permission_classes = [IsAuthenticated]

    def delete(self, request, *args, **kwargs):
        user = request.user
        like = get_object_or_404(Like, user=user, post=kwargs["id"])
        like.delete()
        return Response(
            {"detail": "Like removed"}, status=status.HTTP_204_NO_CONTENT
        )

class CommentCreateView(CreateAPIView):
    serializer_class = CommentSerializer
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        post = get_object_or_404(Post, id=request.data.get("post"))
        serializer = self.get_serializer(data=request.data)

        if serializer.is_valid():
            serializer.save(user=user, post=post)
            notification = Notification.objects.create(
                user=post.user,
                sender=user,
                notification_type="comment",
                post=post,
            )
            send_notification(post.user, {
                'id': notification.id,
                'sender': user.username,
                'notification_type': notification.notification_type,
                'created_at': notification.created_at,
                'post': post.id,
                'seen': notification.seen,
            })
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class CommentDeleteView(DestroyAPIView):
    serializer_class = CommentSerializer
    permission_classes = [IsAuthenticated]

    def delete(self, request, *args, **kwargs):
        user = request.user
        comment = get_object_or_404(Comment, user=user, post=kwargs["id"])
        comment.delete()
        return Response(
            {"detail": "Comment removed"}, status=status.HTTP_204_NO_CONTENT
        )

class NotificationReadAllView(UpdateAPIView):
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def patch(self, request, *args, **kwargs):
        user = request.user
        user.notifications.all().delete()
        return Response(
            {"detail": "All notifications read"}, status=status.HTTP_200_OK
        )

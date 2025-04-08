from rest_framework import status
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.generics import (
    RetrieveAPIView,
    ListAPIView,
    CreateAPIView,
    UpdateAPIView,
    DestroyAPIView,
    get_object_or_404,
)
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from push_notifications.models import GCMDevice
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from authentification.models import CustomUser
from utilities.redis import redis_client
from .models import Follow, Post, Like, Comment, Notification, WorldPosition
from .serializers import (
    UserSerializer,
    PostSerializer,
    LikeSerializer,
    CommentSerializer,
    NotificationSerializer,
    GCMDeviceSerializer,
    WorldPositionSerializer,
)

def send_push_notification(user, title, message):
    devices = GCMDevice.objects.filter(user=user)

    for device in devices:
        device.send_message(title=title, message=message)

def send_notification(user, notification_data):
    channel_layer = get_channel_layer()
    group_name = f"notifications_{user.id}"

    if redis_client.exists(f"user_{user.id}"):
        async_to_sync(channel_layer.group_send)(
            group_name,
            {
                "type": "send_notification",
                "message": {
                    "data": notification_data,
                },
            },
        )
    else:
        message = ""

        if notification_data["notification_type"] == "like":
            message = f"{notification_data['sender']} liked your post"
        elif notification_data["notification_type"] == "comment":
            message = f"{notification_data['sender']} commented on your post"
        elif notification_data["notification_type"] == "follow":
            message = f"{notification_data['sender']} followed you"
        elif notification_data["notification_type"] == "post":
            message = f"{notification_data['sender']} posted"

        send_push_notification(user, "Playfit", message)

class GCMDeviceCreateView(CreateAPIView):
    serializer_class = GCMDeviceSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
            request_body=GCMDeviceSerializer,
            responses={
                201: openapi.Response("Device registered", GCMDeviceSerializer),
                400: openapi.Response(
                    description="Bad request",
                    schema=openapi.Schema(
                        type=openapi.TYPE_OBJECT,
                        properties={
                            'errors': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_STRING)),
                        },
                    ),
                ),
            }
    )
    def post(self, request, *args, **kwargs):
        user = request.user
        serializer = self.get_serializer(data=request.data)

        if serializer.is_valid():
            serializer.save(user=user)
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class FollowersListView(ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
            responses={
                200: openapi.Response(
                    description="List of followers",
                    schema=openapi.Schema(
                        type=openapi.TYPE_ARRAY,
                        items=openapi.Schema(
                            type=openapi.TYPE_OBJECT,
                            properties={
                                'id': openapi.Schema(type=openapi.TYPE_INTEGER),
                                'follower': openapi.Schema(type=openapi.TYPE_OBJECT, ref=UserSerializer),
                                'following': openapi.Schema(type=openapi.TYPE_OBJECT, ref=UserSerializer),
                                'created_at': openapi.Schema(type=openapi.TYPE_STRING, format=openapi.FORMAT_DATETIME),
                            },
                        ),
                    ),
                ),
                400: openapi.Response(
                    description="Bad request",
                    schema=openapi.Schema(
                        type=openapi.TYPE_OBJECT,
                        properties={
                            'errors': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_STRING)),
                        },
                    ),
                ),
            }
    )
    def get_queryset(self):
        user: CustomUser = self.request.user
        return user.get_followers()


class FollowingListView(ListAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
            responses={
                200: openapi.Response(
                    description="List of following",
                    schema=openapi.Schema(
                        type=openapi.TYPE_ARRAY,
                        items=openapi.Schema(
                            type=openapi.TYPE_OBJECT,
                            properties={
                                'id': openapi.Schema(type=openapi.TYPE_INTEGER),
                                'follower': openapi.Schema(type=openapi.TYPE_OBJECT, ref=UserSerializer),
                                'following': openapi.Schema(type=openapi.TYPE_OBJECT, ref=UserSerializer),
                                'created_at': openapi.Schema(type=openapi.TYPE_STRING, format=openapi.FORMAT_DATETIME),
                            },
                        ),
                    ),
                ),
                400: openapi.Response(
                    description="Bad request",
                    schema=openapi.Schema(
                        type=openapi.TYPE_OBJECT,
                        properties={
                            'errors': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_STRING)),
                        },
                    ),
                ),
            }
    )
    def get_queryset(self):
        user: CustomUser = self.request.user
        return user.get_following()


class FollowCreateView(CreateAPIView):
    serializer_class = UserSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        request_body=UserSerializer,
        responses={
            201: openapi.Response("User followed", {"detail": "User followed"}),
            400: openapi.Response(
                description="Bad request",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'detail': openapi.Schema(type=openapi.TYPE_STRING),
                    },
                ),
            ),
            404: openapi.Response(
                description="Not found",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'errors': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_STRING)),
                    },
                ),
            ),
        }
    )
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

    @swagger_auto_schema(
        responses={
            204: openapi.Response("User unfollowed", {"detail": "User unfollowed"}),
            404: openapi.Response(
                description="Not found",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'errors': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_STRING)),
                    },
                ),
            ),
        }
    )
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

    @swagger_auto_schema(
        request_body=PostSerializer,
        responses={
            201: openapi.Response("Post created", PostSerializer),
            400: openapi.Response(
                description="Bad request",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'errors': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_STRING)),
                    },
                ),
            ),
        }
    )
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

    @swagger_auto_schema(
        responses={
            200: openapi.Response(
                description="List of posts",
                schema=openapi.Schema(
                    type=openapi.TYPE_ARRAY,
                    items=openapi.Schema(
                        type=openapi.TYPE_OBJECT,
                        properties={
                            'id': openapi.Schema(type=openapi.TYPE_INTEGER),
                            'user': openapi.Schema(type=openapi.TYPE_OBJECT, ref=UserSerializer),
                            'content': openapi.Schema(type=openapi.TYPE_STRING),
                            'media': openapi.Schema(type=openapi.TYPE_STRING),
                            'created_at': openapi.Schema(type=openapi.TYPE_STRING, format=openapi.FORMAT_DATETIME),
                            # 'likes': openapi.Schema(type=openapi.TYPE_INTEGER),
                            # 'comments': openapi.Schema(type=openapi.TYPE_INTEGER),
                        },
                    ),
                ),
            ),
            400: openapi.Response(
                description="Bad request",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'errors': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_STRING)),
                    },
                ),
            ),
        }
    )
    def get_queryset(self):
        user: CustomUser = self.request.user
        if self.request.query_params.get("profile"):
            return user.posts.all()
        return Post.objects.filter(user__in=user.get_following())

class LikePostView(CreateAPIView):
    serializer_class = LikeSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        request_body=LikeSerializer,
        responses={
            201: openapi.Response("Post liked", {"detail": "Post liked"}),
            400: openapi.Response(
                description="Bad request",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'detail': openapi.Schema(type=openapi.TYPE_STRING),
                    },
                ),
            ),
            404: openapi.Response(
                description="Not found",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'errors': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_STRING)),
                    },
                ),
            ),
        }
    )
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

    @swagger_auto_schema(
        responses={
            204: openapi.Response("Like removed", {"detail": "Like removed"}),
            404: openapi.Response(
                description="Not found",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'errors': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_STRING)),
                    },
                ),
            ),
        }
    )
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

    @swagger_auto_schema(
        request_body=CommentSerializer,
        responses={
            201: openapi.Response("Comment created", CommentSerializer),
            400: openapi.Response(
                description="Bad request",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'errors': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_STRING)),
                    },
                ),
            ),
        }
    )
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

    @swagger_auto_schema(
        responses={
            204: openapi.Response("Comment removed", {"detail": "Comment removed"}),
            404: openapi.Response(
                description="Not found",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'errors': openapi.Schema(type=openapi.TYPE_ARRAY, items=openapi.Schema(type=openapi.TYPE_STRING)),
                    },
                ),
            ),
        }
    )
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

    @swagger_auto_schema(
        responses={
            200: openapi.Response("All notifications read", {"detail": "All notifications read"}),
        }
    )
    def patch(self, request, *args, **kwargs):
        user = request.user
        user.notifications.all().delete()
        return Response(
            {"detail": "All notifications read"}, status=status.HTTP_200_OK
        )

class WorldPositionView(RetrieveAPIView):
    serializer_class = WorldPositionSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        responses={
            200: openapi.Response(
                description="User's world position",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'user': openapi.Schema(type=openapi.TYPE_OBJECT, ref=UserSerializer),
                        'status': openapi.Schema(type=openapi.TYPE_STRING),
                        'continent': openapi.Schema(type=openapi.TYPE_STRING),
                        'country': openapi.Schema(type=openapi.TYPE_STRING),
                        'city': openapi.Schema(type=openapi.TYPE_STRING),
                        'level': openapi.Schema(type=openapi.TYPE_INTEGER),
                    },
                ),
            ),
        }
    )
    def get_object(self):
        user = self.request.user
        position = WorldPosition.objects.get(user=user)
        return position

class FollowingWorldPositionView(ListAPIView):
    serializer_class = WorldPositionSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        responses={
            200: openapi.Response(
                description="Following's world positions",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'user': openapi.Schema(type=openapi.TYPE_OBJECT, ref=UserSerializer),
                        'status': openapi.Schema(type=openapi.TYPE_STRING),
                        'continent': openapi.Schema(type=openapi.TYPE_STRING),
                        'country': openapi.Schema(type=openapi.TYPE_STRING),
                        'city': openapi.Schema(type=openapi.TYPE_STRING),
                        'level': openapi.Schema(type=openapi.TYPE_INTEGER),
                    },
                ),
            )
        }
    )
    def get_queryset(self):
        user: CustomUser = self.request.user
        return WorldPosition.objects.filter(user__in=user.get_following())

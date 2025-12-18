from django.utils import timezone
from django.core.exceptions import ValidationError
from rest_framework import status, filters
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.generics import (
    RetrieveAPIView,
    ListAPIView,
    CreateAPIView,
    UpdateAPIView,
    DestroyAPIView,
    get_object_or_404,
)
from rest_framework.pagination import PageNumberPagination
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from authentification.models import CustomUser
from .models import (
    Follow,
    Post,
    Like,
    Comment,
    Notification,
    WorldPosition,
    CustomizationItem,
    Customization,
    Country,
    City,
    DecorationImage,
    CityDecorationImage,
    BaseCharacter,
    IntroductionCharacter,
    ShopItem,
    ShopPurchase,
)
from .serializers import (
    UserSerializer,
    PostSerializer,
    PostListSerializer,
    LikeSerializer,
    CommentSerializer,
    NotificationSerializer,
    GCMDeviceSerializer,
    WorldPositionResponseSerializer,
    CustomizationItemSerializer,
    CustomizationSerializer,
    UserSearchSerializer,
    ShopItemSerializer,
)
from .utils import send_notification

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
            201: openapi.Response(
                description="User followed successfully",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'detail': openapi.Schema(type=openapi.TYPE_STRING),
                    },
                ),
            ),
            400: openapi.Response(
                description="Bad request",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={'detail': openapi.Schema(type=openapi.TYPE_STRING)},
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
            204: openapi.Response("User unfollowed"),
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

class PostDetailView(RetrieveAPIView):
    serializer_class = PostSerializer
    permission_classes = [IsAuthenticated]
    queryset = Post.objects.all()
    lookup_field = "id"

    @swagger_auto_schema(
        responses={
            200: openapi.Response("Post retrieved", PostSerializer),
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
    def get(self, request, *args, **kwargs):
        post = self.get_object()
        serializer = self.get_serializer(post, context={"request": request})
        return Response(serializer.data)

class PostListView(ListAPIView):
    serializer_class = PostListSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user: CustomUser = self.request.user
        followings = user.get_following()

        # Get posts from their followings of the last 2 weeks
        posts = (Post.objects.filter(
            user__in=followings,
            created_at__gte=timezone.now() - timezone.timedelta(weeks=2)
        )
        .select_related("user__customizations__base_character")
        .order_by("-created_at"))

        return posts

class LikePostView(CreateAPIView):
    serializer_class = LikeSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        request_body=LikeSerializer,
        responses={
            201: openapi.Response("Post liked"),
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
            204: openapi.Response("Like removed"),
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
            204: openapi.Response("Comment removed"),
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
            200: openapi.Response("All notifications read"),
        }
    )
    def patch(self, request, *args, **kwargs):
        user = request.user
        user.notifications.all().delete()
        return Response(
            {"detail": "All notifications read"}, status=status.HTTP_200_OK
        )

class WorldPositionsListView(ListAPIView):
    serializer_class = WorldPositionResponseSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        responses={
            200: openapi.Response(
                description="List of world positions",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'user': openapi.Schema(type=openapi.TYPE_OBJECT, ref='#/definitions/User'),
                        'character': openapi.Schema(type=openapi.TYPE_OBJECT, ref='#/definitions/Customization'),
                        'status': openapi.Schema(type=openapi.TYPE_STRING, enum=["in_city", "in_transition"]),
                        'continent': openapi.Schema(type=openapi.TYPE_STRING),
                        'country': openapi.Schema(type=openapi.TYPE_STRING),
                        'city': openapi.Schema(type=openapi.TYPE_STRING, description="City name (if in city)"),
                        'transition_from': openapi.Schema(type=openapi.TYPE_STRING, description="City from (if in transition)"),
                        'transition_to': openapi.Schema(type=openapi.TYPE_STRING, description="City to (if in transition)"),
                        'level': openapi.Schema(type=openapi.TYPE_INTEGER),
                    },
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
    def get(self, request, *args, **kwargs):
        user: CustomUser = self.request.user
        customization = get_object_or_404(Customization, user=user)
        world_position = get_object_or_404(WorldPosition, user=user)
        followings = user.get_following()
        world_positions = []

        world_positions.append({
            'user': user,
            'customization': customization,
            'position': world_position,
            'country_color': world_position.country.color,
        })
        for following in followings:
            customization = get_object_or_404(Customization, user=following)
            world_position = get_object_or_404(WorldPosition, user=following)
            world_positions.append({
                'user': following,
                'customization': customization,
                'position': world_position,
                'country_color': world_position.country.color,
            })
        serializer = WorldPositionResponseSerializer(world_positions, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)


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
        # serializer = CustomizationSerializer(customization, data=request.data, partial=True)
        # serializer.is_valid(raise_exception=True)
        # serializer.save()
        # return Response(serializer.data)

        if 'base_character' in request.data:
            base_character_name = request.data['base_character']
            base_character = get_object_or_404(BaseCharacter, name=base_character_name)

            # If the outfit is tied to a shop item, ensure the user owns it
            has_shop_entry = ShopItem.objects.filter(base_character=base_character, is_active=True).exists()
            has_purchase = ShopPurchase.objects.filter(user=user, item__base_character=base_character).exists()
            if has_shop_entry and not has_purchase:
                return Response({"detail": "You need to buy this outfit in the shop first"}, status=status.HTTP_403_FORBIDDEN)

            customization.base_character = base_character
            customization.save()
            return Response({"detail": "Customization updated"}, status=status.HTTP_200_OK)
        else:
            return Response({"detail": "Invalid data"}, status=status.HTTP_400_BAD_REQUEST)

class CustomizationView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user: CustomUser = request.user
        customization = Customization.objects.get(user=user)
        serializer = CustomizationSerializer(customization)
        return Response(serializer.data)

class ShopItemListView(ListAPIView):
    serializer_class = ShopItemSerializer
    permission_classes = [IsAuthenticated]
    queryset = ShopItem.objects.filter(is_active=True)
    pagination_class = None

    def list(self, request, *args, **kwargs):
        serializer = self.get_serializer(self.get_queryset(), many=True, context={'request': request})
        progress = getattr(request.user, "progress", None)
        coins = progress.coins if progress else 0
        return Response({"coins": coins, "items": serializer.data}, status=status.HTTP_200_OK)

class ShopPurchaseView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Purchase an item from the shop",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            properties={
                'item_id': openapi.Schema(type=openapi.TYPE_INTEGER, description="ID of the shop item"),
            },
            required=['item_id'],
        ),
        responses={
            200: openapi.Response(
                description="Purchase successful",
                schema=openapi.Schema(
                    type=openapi.TYPE_OBJECT,
                    properties={
                        'detail': openapi.Schema(type=openapi.TYPE_STRING),
                        'coins': openapi.Schema(type=openapi.TYPE_INTEGER),
                    },
                ),
            ),
            400: openapi.Response("Bad request"),
            403: openapi.Response("Forbidden"),
            404: openapi.Response("Not found"),
        }
    )
    def post(self, request):
        user = request.user
        item_id = request.data.get("item_id")
        if not item_id:
            return Response({"detail": "item_id is required"}, status=status.HTTP_400_BAD_REQUEST)

        progress = getattr(user, "progress", None)
        if progress is None:
            return Response({"detail": "User progress not found"}, status=status.HTTP_400_BAD_REQUEST)

        item = get_object_or_404(ShopItem, id=item_id, is_active=True)

        if ShopPurchase.objects.filter(user=user, item=item).exists():
            return Response({"detail": "Item already purchased"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            progress.spend_coins(item.price)
        except ValidationError as e:
            message = e.messages[0] if hasattr(e, "messages") and e.messages else str(e)
            return Response({"detail": message}, status=status.HTTP_400_BAD_REQUEST)

        ShopPurchase.objects.create(user=user, item=item)
        item_data = ShopItemSerializer(item, context={'request': request}).data
        return Response(
            {"detail": "Purchase successful", "coins": progress.coins, "item": item_data},
            status=status.HTTP_200_OK,
        )

class UserWalletView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        progress = getattr(request.user, "progress", None)
        coins = progress.coins if progress else 0
        return Response({"coins": coins}, status=status.HTTP_200_OK)

class GetCharacterImagesView(APIView):
    permission_classes = []

    def get_registration_images(self) -> dict:
        """Retrieve images for character registration.
        Returns:
            dict: A dictionary containing character images categorized by character and color.
        """
        base_characters = BaseCharacter.objects.filter(name__icontains='outfit1')
        data = {
            'character1': {
                'white': [],
                'black': [],
                'introduction': {
                    'white': [],
                    'black': [],
                },
            },
            'character2': {
                'white': [],
                'black': [],
                'introduction': {
                    'white': [],
                    'black': [],
                },
            },
            'character3': {
                'white': [],
                'black': [],
                'introduction': {
                    'white': [],
                    'black': [],
                },
            },
            'character4': {
                'white': [],
                'black': [],
                'introduction': {
                    'white': [],
                    'black': [],
                },
            },
        }

        for character in base_characters:
            parts = character.name.split("-")
            if len(parts) < 3:
                continue
            key, color, _ = parts
            if key in data and color in data[key]:
                data[key][color].append({
                    'id': character.id,
                    'name': character.name,
                    'image': character.image.url,
                })
                # Get introduction images
                introduction_images = IntroductionCharacter.objects.filter(base_character=character)
                for intro_image in introduction_images:
                    data[key]['introduction'][color].append({
                        'id': intro_image.id,
                        'name': intro_image.name,
                        'image': intro_image.image.url,
                    })
        return data

    def get_customization_images(self, user: CustomUser) -> dict:
        """Retrieve images for character customization.
        Returns:
            dict: A dictionary containing character images categorized by character and color.
        """
        base_characters = BaseCharacter.objects.all()
        purchased_base_ids = set(
            ShopPurchase.objects.filter(user=user).values_list('item__base_character_id', flat=True)
        )
        shop_locked_base_ids = set(
            ShopItem.objects.filter(base_character__isnull=False, is_active=True).values_list('base_character_id', flat=True)
        )
        data = {
            'character1': {
                'white': [],
                'black': [],
            },
            'character2': {
                'white': [],
                'black': [],
            },
            'character3': {
                'white': [],
                'black': [],
            },
            'character4': {
                'white': [],
                'black': [],
            },
        }

        for character in base_characters:
            parts = character.name.split("-")
            if len(parts) < 3:
                continue
            key, color, _ = parts
            if key in data and color in data[key]:
                owned = character.id not in shop_locked_base_ids or character.id in purchased_base_ids
                data[key][color].append({
                    'id': character.id,
                    'name': character.name,
                    'image': character.image.url,
                    'owned': owned,
                })
        return data

    def get(self, request):
        registration = request.query_params.get('registration', 'false').lower() == 'true'

        if registration:
            data = self.get_registration_images()
        else:
            # For customization images, the user has to be authenticated
            if not request.user.is_authenticated:
                return Response(
                    {"detail": "Authentication required for customization images"},
                    status=status.HTTP_401_UNAUTHORIZED
                )
            data = self.get_customization_images(request.user)

        return Response(data, status=status.HTTP_200_OK)

class GetDecorationImagesView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, country: str):
        c: Country = get_object_or_404(Country, name=country)
        cities = City.objects.filter(country=c)
        decoration_images = {
            'tree': DecorationImage.objects.get(label__iexact=f'tree_{c.name}').image.url,
            'building': DecorationImage.objects.get(label__iexact=f'building_{c.name}').image.url,
            'flag': DecorationImage.objects.get(label='flag').image.url,
            'path': DecorationImage.objects.get(label__iexact=f'path_{c.name}').image.url,
            'country': [],
        }

        for city in cities:
            images = CityDecorationImage.objects.filter(city=city)
            temp_images = []

            for image in images:
                temp_images.append(image.image.url)
            decoration_images['country'].append(temp_images)

        return Response(decoration_images, status=status.HTTP_200_OK)

class UserSearchPagination(PageNumberPagination):
    page_size = 10
    page_size_query_param = 'page_size'

class UserSearchView(ListAPIView):
    serializer_class = UserSearchSerializer
    permission_classes = [IsAuthenticated]
    pagination_class = UserSearchPagination
    queryset = CustomUser.objects.filter(is_active=True)
    filter_backends = [filters.SearchFilter]
    search_fields = ['username']

# Get user progress

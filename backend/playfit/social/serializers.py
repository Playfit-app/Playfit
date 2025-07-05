from rest_framework import serializers
from django.contrib.auth import get_user_model
from push_notifications.models import GCMDevice
from .models import (
    Post,
    Like,
    Comment,
    Notification,
    WorldPosition,
    BaseCharacter,
    CustomizationItem,
    Customization,
)

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    base_character = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ["id", "username", "base_character"]

    def get_base_character(self, obj):
        customization = getattr(obj, 'customizations', None)
        if customization and customization.base_character:
            return customization.base_character.image.url
        return None

class BaseCharacterSerializer(serializers.ModelSerializer):
    class Meta:
        model = BaseCharacter
        fields = ["id", "name", "image"]

    image = serializers.ImageField(use_url=True)

class CustomizationItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomizationItem
        fields = ["id", "name", "category", "image"]

    image = serializers.ImageField(use_url=True)

class CustomizationSerializer(serializers.ModelSerializer):
    base_character = BaseCharacterSerializer()
    hat = CustomizationItemSerializer()
    backpack = CustomizationItemSerializer()
    shirt = CustomizationItemSerializer()
    pants = CustomizationItemSerializer()
    shoes = CustomizationItemSerializer()
    gloves = CustomizationItemSerializer()

    class Meta:
        model = Customization
        fields = ["base_character", "hat", "backpack", "shirt", "pants", "shoes", "gloves"]

class GCMDeviceSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = GCMDevice
        fields = ["id", "user", "registration_id"]

class PostListSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    nb_likes = serializers.SerializerMethodField()
    nb_comments = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()
    media = serializers.ImageField(use_url=True)
    is_liked = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = ["id", "user", "content", "media", "created_at", "nb_likes", "nb_comments", "comments", "is_liked"]

    def get_nb_likes(self, obj):
        return obj.likes.count()

    def get_nb_comments(self, obj):
        return obj.comments.count()
    
    def get_comments(self, obj):
        comments = obj.comments.order_by('-created_at')[:3]
        return CommentSerializer(comments, many=True).data

    def get_is_liked(self, obj):
        request = self.context.get("request")

        if request and request.user.is_authenticated:
            return obj.likes.filter(user=request.user).exists()
        return False

class PostSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    nb_likes = serializers.SerializerMethodField()
    nb_comments = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()
    media = serializers.ImageField(use_url=True)
    is_liked = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = ["id", "user", "content", "media", "created_at", "nb_likes", "nb_comments", "comments", "is_liked"]

    def get_nb_likes(self, obj):
        return obj.likes.count()

    def get_nb_comments(self, obj):
        return obj.comments.count()
    
    def get_comments(self, obj):
        comments = obj.comments.all()
        return CommentSerializer(comments, many=True).data

    def get_is_liked(self, obj):
        request = self.context.get("request")

        if request and request.user.is_authenticated:
            return obj.likes.filter(user=request.user).exists()
        return False

class LikeSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = Like
        fields = ["id", "user", "created_at"]

class CommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = Comment
        fields = ["id", "user", "content", "created_at"]

class NotificationSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    sender = UserSerializer(read_only=True)
    post = PostSerializer(read_only=True)

    class Meta:
        model = Notification
        fields = ["id", "user", "sender", "notification_type", "post", "created_at"]

class WorldPositionResponseSerializer(serializers.Serializer):
    user = UserSerializer(read_only=True)
    character = CustomizationSerializer()
    status = serializers.CharField()
    continent = serializers.CharField()
    country = serializers.CharField()
    city = serializers.CharField(required=False)
    city_from = serializers.CharField(required=False)
    city_to = serializers.CharField(required=False)
    level = serializers.IntegerField()

    def to_representation(self, instance):
        user = instance['user']
        customization: Customization = instance['customization']
        position: WorldPosition = instance['position']

        if position.is_in_city():
            return {
                'user': UserSerializer(user).data,
                'character': CustomizationSerializer(customization).data,
                'status': "in_city",
                'continent': position.city.country.continent.name,
                'country': position.city.country.name,
                'city': position.city.order,
                'level': position.city_level,
                'max_level': position.city.max_level,
                'country_color': position.city.country.color,
                'city_name': position.city.name,
            }
        else:
            return {
                'user': UserSerializer(user).data,
                'character': CustomizationSerializer(customization).data,
                'status': "in_transition",
                'continent': position.transition_from.country.continent.name,
                'country': position.transition_from.country.name,
                'city_from': position.transition_from.order,
                'city_to': position.transition_to.order,
                'level': position.transition_level,
                'max_level': 4,
                'country_color': position.transition_from.country.color,
            }

class UserSearchSerializer(serializers.ModelSerializer):
    customizations = CustomizationSerializer()

    class Meta:
        model = User
        fields = ["id", "username", "customizations"]

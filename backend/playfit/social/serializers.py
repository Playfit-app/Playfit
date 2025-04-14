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
    class Meta:
        model = User
        fields = ["id", "username"]

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

class PostSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    likes = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()

    class Meta:
        model = Post
        fields = ["id", "user", "content", "media", "created_at", "likes", "comments"]

    def get_likes(self, obj):
        return obj.likes.count()

    def get_comments(self, obj):
        return obj.comments.count()

class LikeSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    post = PostSerializer(read_only=True)

    class Meta:
        model = Like
        fields = ["id", "user", "post", "created_at"]

class CommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    post = PostSerializer(read_only=True)

    class Meta:
        model = Comment
        fields = ["id", "user", "post", "content", "created_at"]

class NotificationSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    sender = UserSerializer(read_only=True)
    post = PostSerializer(read_only=True)

    class Meta:
        model = Notification
        fields = ["id", "user", "sender", "notification_type", "post", "created_at"]

# class WorldPositionSerializer(serializers.ModelSerializer):
#     user = UserSerializer(read_only=True)

#     class Meta:
#         model = WorldPosition
#         fields = "__all__"

#     def to_representation(self, instance):
#         base = super().to_representation(instance)

#         if instance.is_in_city():
#             return {

#             }

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
            }

from rest_framework import serializers
from django.contrib.auth import get_user_model
from push_notifications.models import GCMDevice
from .models import Post, Like, Comment, Notification, WorldPosition, CustomizationItem, Customization

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["id", "username"]

class CustomizationItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomizationItem
        fields = ["id", "name", "category", "image"]

    image = serializers.ImageField(use_url=True)

class CustomizationSerializer(serializers.ModelSerializer):
    hat = CustomizationItemSerializer()
    backpack = CustomizationItemSerializer()
    shirt = CustomizationItemSerializer()
    pants = CustomizationItemSerializer()
    shoes = CustomizationItemSerializer()
    gloves = CustomizationItemSerializer()

    class Meta:
        model = Customization
        fields = ["hat", "backpack", "shirt", "pants", "shoes", "gloves"]

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

class WorldPositionSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = WorldPosition
        fields = "__all__"

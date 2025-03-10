from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import CustomizationItem, Customization

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
    gloves = CustomizationItemSerializer

    class Meta:
        model = Customization
        fields = ["hat", "backpack", "shirt", "pants", "shoes", "gloves"]

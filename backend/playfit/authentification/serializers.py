import django.contrib.auth.password_validation as validators
from rest_framework import serializers
from .models import CustomUser

class CustomUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = CustomUser
        fields = [
            'email', 'username', 'password', 'first_name', 'last_name', 'date_of_birth', 'height', 'weight',
            'gender', 'fitness_level', 'goals', 'physical_particularities'
        ]

    def create(self, validated_data):
        user = CustomUser(
            email=validated_data['email'],
            username=validated_data['username'],
            first_name=validated_data['first_name'],
            last_name=validated_data['last_name'],
            date_of_birth=validated_data['date_of_birth'],
            height=validated_data['height'],
            weight=validated_data['weight'],
            gender=validated_data['gender'],
            fitness_level=validated_data['fitness_level'],
            goals=validated_data['goals'],
            physical_particularities=validated_data['physical_particularities']
        )
        user.set_password(validated_data['password'])
        user.save()
        return user

    def validate(self, value):
        user = CustomUser(
            email=value['email'],
            username=value['username'],
            first_name=value['first_name'],
            last_name=value['last_name'],
            date_of_birth=value['date_of_birth'],
            height=value['height'],
            weight=value['weight'],
            gender=value['gender'],
            fitness_level=value['fitness_level'],
            goals=value['goals'],
            physical_particularities=value['physical_particularities']
        )
        password = value['password']
        errors = dict()
        try:
            validators.validate_password(password=password, user=user)
        except serializers.ValidationError as e:
            errors['password'] = list(e.messages)
        if errors:
            raise serializers.ValidationError(errors)
        return value

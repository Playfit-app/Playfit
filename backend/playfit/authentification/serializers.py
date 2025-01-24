import django.contrib.auth.password_validation as validators
from rest_framework import serializers
from .models import CustomUser, UserConsent

class CustomUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    terms_and_conditions = serializers.BooleanField(write_only=True)
    privacy_policy = serializers.BooleanField(write_only=True)
    marketing = serializers.BooleanField(write_only=True)

    class Meta:
        model = CustomUser
        fields = [
            'email', 'username', 'password', 'date_of_birth', 'height', 'weight',
            'terms_and_conditions', 'privacy_policy', 'marketing'
        ]

    def create(self, validated_data):
        user = CustomUser(
            email=validated_data['email'],
            username=validated_data['username'],
            date_of_birth=validated_data['date_of_birth'],
            height=validated_data['height'],
            weight=validated_data['weight'],
        )
        user.set_password(validated_data['password'])
        user.email_hash = hash(validated_data['email'])
        user.save()

        UserConsent.objects.create(
            user=user,
            terms_and_conditions=validated_data['terms_and_conditions'],
            privacy_policy=validated_data['privacy_policy'],
            marketing=validated_data['marketing']
        )
        return user

    def validate(self, value):
        user = CustomUser(
            email=value['email'],
            username=value['username'],
            date_of_birth=value['date_of_birth'],
            height=value['height'],
            weight=value['weight'],
        )
        password = value['password']
        errors = dict()
        try:
            validators.validate_password(password=password, user=user)
        except serializers.ValidationError as e:
            errors['password'] = list(e.messages)
        if errors:
            raise serializers.ValidationError(errors)
        if not value['terms_and_conditions'] or not value['privacy_policy']:
            raise serializers.ValidationError("You must accept the terms and conditions and privacy policy to register.")
        return value

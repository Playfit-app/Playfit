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

class UserConsentSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserConsent
        fields = ['terms_and_conditions', 'privacy_policy', 'marketing']

class CustomUserRetrieveSerializer(serializers.ModelSerializer):
    consent = UserConsentSerializer(source='userconsent', read_only=True)

    class Meta:
        model = CustomUser
        fields = [
            'email', 'username', 'first_name', 'last_name', 'date_of_birth', 'height', 'weight',
            'goals', 'gender', 'fitness_level', 'physical_particularities', 'date_joined',
            'last_login', 'registration_method', 'consent'
        ]

class CustomUserUpdateSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = [
            'username', 'first_name', 'last_name', 'height', 'weight',
            'goals', 'gender', 'fitness_level', 'physical_particularities'
        ]
        extra_kwargs = {
            'username': {'required': False},
            'first_name': {'required': False},
            'last_name': {'required': False},
            'height': {'required': False},
            'weight': {'required': False},
            'goals': {'required': False},
            'gender': {'required': False},
            'fitness_level': {'required': False},
            'physical_particularities': {'required': False},
        }

    def validate(self, data):
        if 'username' in data and CustomUser.objects.filter(username=data['username']).exclude(id=self.instance.id).exists():
            raise serializers.ValidationError({'username': 'Username already exists'})
        if 'height' in data and (data['height'] < 100 or data['height'] > 250):
            raise serializers.ValidationError({'height': 'Height must be between 100 and 250 cm'})
        if 'weight' in data and (data['weight'] < 30 or data['weight'] > 250):
            raise serializers.ValidationError({'weight': 'Weight must be between 30 and 250 kg'})
        if 'goals' in data and data['goals'] not in [CustomUser.BODYWEIGHT_STRENGTH, CustomUser.FAT_LOSS_CARDIO, CustomUser.ENDURANCE]:
            raise serializers.ValidationError({'goals': 'Invalid goals value'})
        if 'gender' in data and data['gender'] not in ["Male", "Female", "Other"]:
            raise serializers.ValidationError({'gender': 'Invalid gender value'})
        if 'fitness_level' in data and data['fitness_level'] not in ["Beginner", "Intermediate", "Advanced"]:
            raise serializers.ValidationError({'fitness_level': 'Invalid fitness level value'})
        if 'physical_particularities' in data and len(data['physical_particularities']) > 1000:
            raise serializers.ValidationError({'physical_particularities': 'Physical particularities must be less than 1000 characters'})
        return data

class CustomUserDeleteSerializer(serializers.Serializer):
    confirm = serializers.BooleanField(write_only=True)

    def validate(self, data):
        if not data['confirm']:
            raise serializers.ValidationError({'confirm': 'You must confirm the deletion'})
        return data

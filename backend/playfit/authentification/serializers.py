import django.contrib.auth.password_validation as validators
from rest_framework import serializers
from utilities.encrypted_fields import hash
from .models import CustomUser, UserConsent, UserAchievement

class CustomUserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)
    terms_and_conditions = serializers.BooleanField(write_only=True)
    privacy_policy = serializers.BooleanField(write_only=True)
    marketing = serializers.BooleanField(write_only=True)
    character_image_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = CustomUser
        fields = [
            'email', 'username', 'password', 'date_of_birth', 'height', 'weight',
            'terms_and_conditions', 'privacy_policy', 'marketing', 'character_image_id',
        ]

    def create(self, validated_data):
        return CustomUser.objects.create_user(**validated_data)

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
            raise serializers.ValidationError({'terms_and_conditions': 'You must accept the terms and conditions', 'privacy_policy': 'You must accept the privacy policy'})
        if value['character_image_id'] < 0 or value['character_image_id'] > 4:
            raise serializers.ValidationError({'character_image_id': 'Invalid character image'})
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
        if 'gender' in data and data['gender'] not in ["male", "female", "other"]:
            raise serializers.ValidationError({'gender': 'Invalid gender value'})
        if 'fitness_level' in data and data['fitness_level'] not in ["beginner", "intermediate", "advanced"]:
            raise serializers.ValidationError({'fitness_level': 'Invalid fitness level value'})
        if 'physical_particularities' in data and data['physical_particularities'] and len(data['physical_particularities']) > 1000:
            raise serializers.ValidationError({'physical_particularities': 'Physical particularities must be less than 1000 characters'})
        return data

class CustomUserDeleteSerializer(serializers.Serializer):
    confirm = serializers.BooleanField(write_only=True)

    def validate(self, data):
        if not data['confirm']:
            raise serializers.ValidationError({'confirm': 'You must confirm the deletion'})
        return data

class AccountRecoveryRequestSerializer(serializers.Serializer):
    email = serializers.EmailField()

    def validate(self, data):
        if not CustomUser.objects.filter(email_hash=hash(data['email'])).exists():
            raise serializers.ValidationError({'email': 'Email not found'})
        return data

class UserTestSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['id', 'username']

class UserAchievementSerializer(serializers.ModelSerializer):
    user = UserTestSerializer(read_only=True)
    progress = serializers.DictField()
    class Meta:
        model = UserAchievement
        fields = ['progress', 'user']
    
    def validate(self, data):
        user = self.context['request'].user
        
        if not data:
            raise serializers.ValidationError({'data': 'Data not found'})
        if not data['progress']:
            raise serializers.ValidationError({'progress': 'Progress not found'})
        if not user:
            raise serializers.ValidationError({'user': 'User not found'})
        if data['progress'] == '' or data['progress'] == "":
            raise serializers.ValidationError({'progress': 'Progress cannot be empty'})
        return data
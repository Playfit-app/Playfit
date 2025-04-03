import datetime
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.core.exceptions import ValidationError
from utilities.encrypted_fields import hash, EncryptedCharField, EncryptedEmailField, EncryptedDateField, EncryptedTextField

class CustomUserManager(BaseUserManager):
    def create_user(self, email, username, password, **extra_fields):
        email = self.normalize_email(email)
        terms_and_conditions = extra_fields.pop('terms_and_conditions', True)
        privacy_policy = extra_fields.pop('privacy_policy', True)
        marketing = extra_fields.pop('marketing', False)
        user = self.model(email=email, username=username, **extra_fields)
        user.set_password(password)
        user.email_hash = hash(email)
        user.save()

        UserConsent.objects.create(
            user=user,
            terms_and_conditions=terms_and_conditions,
            privacy_policy=privacy_policy,
            marketing=marketing,
        )
        return user

    def create_superuser(self, email, username, password, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        return self.create_user(email, username, password, **extra_fields)

class CustomUser(AbstractBaseUser, PermissionsMixin):
    BODYWEIGHT_STRENGTH = "bodyWeightStrength"
    FAT_LOSS_CARDIO = "fatLossCardio"
    ENDURANCE = "endurance"

    GOALS_CHOICES = [
        (BODYWEIGHT_STRENGTH, "Bodyweight Strength"),
        (FAT_LOSS_CARDIO, "Fat Loss or Cardio"),
        (ENDURANCE, "Endurance"),
    ]

    GENDER_CHOICES = [
        ("male", "Male"),
        ("female", "Female"),
        ("other", "Other"),
    ]

    FITNESS_LEVEL_CHOICES = [
        ("beginner", "Beginner"),
        ("intermediate", "Intermediate"),
        ("advanced", "Advanced"),
    ]

    REGISTRATION_METHOD_CHOICES = [
        ("email", "Email"),
        ("google", "Google"),
    ]

    email = EncryptedEmailField(unique=True)
    email_hash = models.CharField(max_length=64, unique=True, null=True, blank=True)
    username = models.CharField(max_length=150, unique=True, null=True, blank=True)
    first_name = EncryptedCharField(max_length=150, null=True, blank=True)
    last_name = EncryptedCharField(max_length=150, null=True, blank=True)
    date_of_birth = EncryptedDateField(max_length=10, null=True, blank=True)
    height = models.DecimalField(max_digits=5, decimal_places=2, validators=[MinValueValidator(100.0), MaxValueValidator(250.0)], null=True, blank=True)
    weight = models.DecimalField(max_digits=5, decimal_places=2, validators=[MinValueValidator(30.0), MaxValueValidator(250.0)], null=True, blank=True)
    goals = models.CharField(max_length=50, choices=GOALS_CHOICES, default=BODYWEIGHT_STRENGTH)
    gender = EncryptedCharField(max_length=10, choices=GENDER_CHOICES, default="other", null=True, blank=True)
    fitness_level = models.CharField(max_length=20, choices=FITNESS_LEVEL_CHOICES, default="beginner")
    physical_particularities = EncryptedTextField(null=True, blank=True)
    last_login = models.DateTimeField(auto_now=True)
    date_joined = models.DateTimeField(auto_now_add=True)
    registration_method = models.CharField(max_length=20, choices=REGISTRATION_METHOD_CHOICES, default="email")
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    objects = CustomUserManager()

    USERNAME_FIELD = 'username'
    REQUIRED_FIELDS = [
        'email', 'date_of_birth', 'height', 'weight',
    ]

    def __str__(self):
        return self.username if self.username else f"Anonymous User {self.id}"

    def has_perm(self, perm, obj=None):
        return self.is_superuser

    def has_module_perms(self, app_label):
        return self.is_superuser

    def clean(self):
        super().clean()
        if not self.is_active:
            return
        if isinstance(self.date_of_birth, str):
            try:
                self.date_of_birth = datetime.date.fromisoformat(self.date_of_birth)
            except ValueError:
                raise ValidationError("Invalid date format. Please use YYYY-MM-DD.")

        if self.date_of_birth >= datetime.date.today() - datetime.timedelta(days=365*18):
            raise ValidationError("You must be at least 18 years old to register.")

        if isinstance(self.date_of_birth, datetime.date):
            self.date_of_birth = self.date_of_birth.isoformat()

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

    def anonynimze_user(self):
        self.username = None
        self.first_name = None
        self.last_name = None
        self.date_of_birth = None
        self.height = None
        self.weight = None
        self.gender = None
        self.physical_particularities = None
        self.is_active = False
        self.save()

class UserConsent(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    terms_and_conditions = models.BooleanField(default=False)
    privacy_policy = models.BooleanField(default=False)
    marketing = models.BooleanField(default=False)
    consent_date = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Consent for {self.user.username} - {self.consent_date}"

class GameAchievement(models.Model):
    name = models.CharField(max_length=250)
    description = models.TextField()
    criteria = models.JSONField()
    xp_reward = models.PositiveIntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name

class UserAchievement(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    achievement = models.ForeignKey(GameAchievement, on_delete=models.CASCADE)
    is_completed = models.BooleanField(default=False)
    progress = models.JSONField(default=dict)
    awarded_at = models.DateTimeField(auto_now_add=False, null=True)

    def __str__(self):
        return f"{self.user.username} - {self.achievement.name}"

class UserStats(models.Model):
    user_id = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    total_workouts = models.PositiveIntegerField(default=0)
    longest_streak = models.PositiveIntegerField(default=0)
    current_streak = models.PositiveIntegerField(default=0)

    def __str__(self):
        return f"Stats for {self.user.username}"
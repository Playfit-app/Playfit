from django.db import models
from django.core.exceptions import ValidationError
from django.contrib.auth import get_user_model
from django.utils.text import slugify
from utilities.images import convert_to_webp

User = get_user_model()

def customizations_image_path(instance, filename):
    filename_without_ext = filename.split('.')[0]
    return f'customizations/{instance.category}/{filename_without_ext}.webp'

def city_decoration_image_path(instance, filename):
    filename_without_ext = filename.split('.')[0]
    country_name = slugify(instance.city.country.name)
    city_name = slugify(instance.city.name)
    return f'decorations/countries/{country_name}/{city_name}/{filename_without_ext}.webp'

def mountain_decoration_image_path(instance, filename):
    filename_without_ext = filename.split('.')[0]
    return f'decorations/mountains/{filename_without_ext}.webp'

class CustomizationItem(models.Model):
    CATEGORY_CHOICES = [
        ('hat', 'Hat'),
        ('backpack', 'Backpack'),
        ('shirt', 'Shirt'),
        ('pants', 'Pants'),
        ('shoes', 'Shoes'),
        ('gloves', 'Gloves'),
    ]

    name = models.CharField(max_length=255, unique=True)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES)
    image = models.ImageField(upload_to=customizations_image_path)

    def __str__(self):
        return f"{self.name} ({self.category})"

    def save(self, *args, **kwargs):
        if self.image:
            ext = self.image.name.split('.')[-1].lower()
            if ext == 'png':
                self.image = convert_to_webp(self.image)
            elif ext != 'webp':
                raise ValidationError("The image must be a PNG or WebP file")
        super().save(*args, **kwargs)

class BaseCharacter(models.Model):
    name = models.CharField(max_length=50, unique=True)
    image = models.ImageField(upload_to='base_characters/')

    def __str__(self):
        return self.name

    def save(self, *args, **kwargs):
        if self.image:
            ext = self.image.name.split('.')[-1].lower()
            if ext == 'png':
                self.image = convert_to_webp(self.image)
            elif ext != 'webp':
                raise ValidationError("The image must be a PNG or WebP file")
        super().save(*args, **kwargs)

class Customization(models.Model):
    user = models.OneToOneField(User, related_name='customizations', on_delete=models.CASCADE)
    base_character = models.ForeignKey(BaseCharacter, related_name='character', on_delete=models.SET_NULL, null=True, blank=True)
    hat = models.ForeignKey(CustomizationItem, related_name='hat', on_delete=models.SET_NULL, null=True, blank=True)
    backpack = models.ForeignKey(CustomizationItem, related_name='backpack', on_delete=models.SET_NULL, null=True, blank=True)
    shirt = models.ForeignKey(CustomizationItem, related_name='shirt', on_delete=models.SET_NULL, null=True, blank=True)
    pants = models.ForeignKey(CustomizationItem, related_name='pants', on_delete=models.SET_NULL, null=True, blank=True)
    shoes = models.ForeignKey(CustomizationItem, related_name='shoes', on_delete=models.SET_NULL, null=True, blank=True)
    gloves = models.ForeignKey(CustomizationItem, related_name='gloves', on_delete=models.SET_NULL, null=True, blank=True)

    def __str__(self):
        return f"{self.user}'s customizations ({self.base_character}) - ({self.hat}, {self.backpack}, {self.shirt}, {self.pants}, {self.shoes}, {self.gloves})"

class Follow(models.Model):
    follower = models.ForeignKey(User, related_name='following', on_delete=models.CASCADE)
    following = models.ForeignKey(User, related_name='followers', on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("follower", "following")

    def __str__(self):
        return f"{self.follower} follows {self.following}"

    def clean(self):
        if self.follower == self.following:
            raise ValidationError("You can't follow yourself")

    def save(self, *args, **kwargs):
        self.full_clean()
        super().save(*args, **kwargs)

class Post(models.Model):
    user = models.ForeignKey(User, related_name='posts', on_delete=models.CASCADE)
    content = models.TextField(blank=True, null=True)
    media = models.FileField(upload_to='posts/media/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user} posted on {self.created_at}"

class Like(models.Model):
    user = models.ForeignKey(User, related_name='likes', on_delete=models.CASCADE)
    post = models.ForeignKey(Post, related_name='likes', on_delete=models.CASCADE)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ("user", "post")

    def __str__(self):
        return f"{self.user} liked {self.post}"

class Comment(models.Model):
    user = models.ForeignKey(User, related_name='comments', on_delete=models.CASCADE)
    post = models.ForeignKey(Post, related_name='comments', on_delete=models.CASCADE)
    content = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user} commented on {self.post}"

class Notification(models.Model):
    NOTIFICATION_TYPES = (
        ('like', 'Like'),
        ('comment', 'Comment'),
        ('follow', 'Follow'),
        ('post', 'Post'),
        ('world_position', 'World Position'),
    )

    user = models.ForeignKey(User, related_name='notifications', on_delete=models.CASCADE)
    sender = models.ForeignKey(User, on_delete=models.CASCADE)
    post = models.ForeignKey(Post, null=True, blank=True, on_delete=models.CASCADE)
    notification_type = models.CharField(max_length=25, choices=NOTIFICATION_TYPES)
    created_at = models.DateTimeField(auto_now_add=True)
    seen = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.sender} {self.notification_type} {self.user}"

class Continent(models.Model):
    name = models.CharField(max_length=50, unique=True)

    def __str__(self):
        return self.name

class Country(models.Model):
    name = models.CharField(max_length=50, unique=True)
    continent = models.ForeignKey(Continent, related_name='countries', on_delete=models.CASCADE)

    def __str__(self):
        return self.name

class City(models.Model):
    name = models.CharField(max_length=50)
    country = models.ForeignKey(Country, related_name='cities', on_delete=models.CASCADE)
    order = models.PositiveIntegerField()

    class Meta:
        unique_together = ("country", "order")
        ordering = ['country', 'order']

    def __str__(self):
        return self.name

class WorldPosition(models.Model):
    CITY_LEVEL_CHOICES = [(i, f"Level {i}") for i in range(1, 7)]
    TRANSITION_LEVEL_CHOICES = [(i, f"Level {i}") for i in range(1, 5)]

    user = models.OneToOneField(User, related_name='position', on_delete=models.CASCADE)
    city = models.ForeignKey(City, related_name='users', on_delete=models.SET_NULL, null=True, blank=True)
    city_level = models.PositiveIntegerField(null=True, blank=True, choices=CITY_LEVEL_CHOICES)

    transition_from = models.ForeignKey(City, related_name='departing_users', on_delete=models.SET_NULL, null=True, blank=True)
    transition_to = models.ForeignKey(City, related_name='arriving_users', on_delete=models.SET_NULL, null=True, blank=True)
    transition_level = models.PositiveIntegerField(null=True, blank=True, choices=TRANSITION_LEVEL_CHOICES)

    def is_in_city(self):
        return self.city is not None

    def is_in_transition(self):
        return self.transition_from is not None and self.transition_to is not None

    def move_to_next_level(self):
        if self.is_in_city():
            if self.city_level < 6:
                self.city_level += 1
            else:
                try:
                    next_city = City.objects.get(country=self.city.country, order=self.city.order + 1)
                    if next_city:
                        self.start_transition(next_city)
                except City.DoesNotExist:
                    print("Next city doesn't exist")
        elif self.is_in_transition():
            if self.transition_level < 4:
                self.transition_level += 1
            else:
                self.city = self.transition_to
                self.city_level = 1
                self.transition_from = None
                self.transition_to = None
                self.transition_level = None
        self.save()

    def start_transition(self, next_city):
        self.transition_from = self.city
        self.transition_to = next_city
        self.transition_level = 1
        self.city = None
        self.city_level = None
        self.save()

    def __str__(self):
        if self.is_in_city():
            return f"{self.user} is in {self.city} (Level {self.city_level})"
        elif self.is_in_transition():
            return f"{self.user} is transitioning from {self.transition_from} to {self.transition_to} (Level {self.transition_level})"
        return f"{self.user} is in the void"

class DecorationImage(models.Model):
    image = models.ImageField(upload_to='decorations/')
    label = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.label} decoration ({self.created_at})"

    def save(self, *args, **kwargs):
        if self.image:
            ext = self.image.name.split('.')[-1].lower()
            if ext == 'png':
                self.image = convert_to_webp(self.image)
            elif ext != 'webp':
                raise ValidationError("The image must be a PNG or WebP file")
        super().save(*args, **kwargs)

class CityDecorationImage(models.Model):
    city = models.ForeignKey(City, related_name='decorations', on_delete=models.CASCADE)
    image = models.ImageField(upload_to=city_decoration_image_path)
    label = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.label} decoration for {self.city} ({self.created_at})"

    def save(self, *args, **kwargs):
        if self.image:
            ext = self.image.name.split('.')[-1].lower()
            if ext == 'png':
                self.image = convert_to_webp(self.image)
            elif ext != 'webp':
                raise ValidationError("The image must be a PNG or WebP file")
        super().save(*args, **kwargs)

class MountainDecorationImage(models.Model):
    image = models.ImageField(upload_to=mountain_decoration_image_path)
    label = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.label} decoration ({self.created_at})"

    def save(self, *args, **kwargs):
        if self.image:
            ext = self.image.name.split('.')[-1].lower()
            if ext == 'png':
                self.image = convert_to_webp(self.image)
            elif ext != 'webp':
                raise ValidationError("The image must be a PNG or WebP file")
        super().save(*args, **kwargs)

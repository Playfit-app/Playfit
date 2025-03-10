from django.db import models
from django.core.exceptions import ValidationError
from authentification.models import CustomUser
from .utils import convert_to_webp

def customizations_image_path(instance, filename):
    filename_without_ext = filename.split('.')[0]
    return f'customizations/{instance.category}/{filename_without_ext}.webp'

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

class Customization(models.Model):
    user = models.OneToOneField(CustomUser, related_name='customizations', on_delete=models.CASCADE)
    hat = models.ForeignKey(CustomizationItem, related_name='hat', on_delete=models.SET_NULL, null=True, blank=True)
    backpack = models.ForeignKey(CustomizationItem, related_name='backpack', on_delete=models.SET_NULL, null=True, blank=True)
    shirt = models.ForeignKey(CustomizationItem, related_name='shirt', on_delete=models.SET_NULL, null=True, blank=True)
    pants = models.ForeignKey(CustomizationItem, related_name='pants', on_delete=models.SET_NULL, null=True, blank=True)
    shoes = models.ForeignKey(CustomizationItem, related_name='shoes', on_delete=models.SET_NULL, null=True, blank=True)
    gloves = models.ForeignKey(CustomizationItem, related_name='gloves', on_delete=models.SET_NULL, null=True, blank=True)

    def __str__(self):
        return f"{self.user}'s customizations ({self.hat}, {self.backpack}, {self.shirt}, {self.pants}, {self.shoes}, {self.gloves})"

class Follow(models.Model):
    follower = models.ForeignKey(CustomUser, related_name='following', on_delete=models.CASCADE)
    following = models.ForeignKey(CustomUser, related_name='followers', on_delete=models.CASCADE)
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

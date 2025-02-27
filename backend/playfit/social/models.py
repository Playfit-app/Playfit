from django.db import models
from django.core.exceptions import ValidationError
from authentification.models import CustomUser

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

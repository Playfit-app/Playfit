from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser

class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ['email', 'username', 'first_name', 'last_name', 'date_of_birth', 'height', 'weight', 'last_login', 'date_joined', 'is_active', 'is_staff', 'is_superuser']

admin.site.register(CustomUser, CustomUserAdmin)

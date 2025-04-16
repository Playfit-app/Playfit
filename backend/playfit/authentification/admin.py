from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, GameAchievement, UserAchievement, UserProgress

class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = [
        'email', 'username', 'last_login', 'is_staff', 'is_superuser'
    ]
    list_filter = [
        'is_active', 'is_staff', 'is_superuser', 'gender', 'goals'
    ]
    fieldsets = [
        (None, {'fields': ('email', 'username', 'password')}),
        ('Personal info', {'fields': ('date_of_birth', 'height', 'weight', 'goals', 'gender', 'fitness_level', 'physical_particularities')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser')}),
    ]
    add_fieldsets = [
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'username', 'password1', 'password2'),
        }),
    ]

class UserAchievementAdmin(admin.ModelAdmin):
    list_display = ['user', 'achievement']
    search_fields = ['user__username', 'achievement__name']


admin.site.register(CustomUser, CustomUserAdmin)
admin.site.register(GameAchievement)
admin.site.register(UserAchievement, UserAchievementAdmin)
admin.site.register(UserProgress)

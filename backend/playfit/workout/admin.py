from django.contrib import admin
from .models import Exercise

class ExerciseAdmin(admin.ModelAdmin):
    model = Exercise
    list_display = [
        'name', 'difficulty'
    ]
    list_filter = [
        'difficulty'
    ]
    fieldsets = [
        (None, {'fields': ('name', 'description', 'video_url', 'difficulty')}),
    ]
    add_fieldsets = [
        (None, {
            'classes': ('wide',),
            'fields': ('name', 'description', 'video_url', 'difficulty'),
        }),
    ]

admin.site.register(Exercise, ExerciseAdmin)

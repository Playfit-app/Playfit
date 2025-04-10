from django.contrib import admin
from .models import Exercise, WorkoutSession, WorkoutSessionExercise

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

class WorkoutSessionAdmin(admin.ModelAdmin):
    model = WorkoutSession
    list_display = [
        'user', 'duration', 'creation_date', 'completed_date'
    ]
    list_filter = [
        'user', 'creation_date'
    ]

class WorkoutSessionExerciseAdmin(admin.ModelAdmin):
    model = WorkoutSessionExercise
    list_display = [
        'workout_session', 'exercise', 'sets', 'repetitions', 'weight'
    ]
    list_filter = [
        'workout_session', 'exercise'
    ]
    fieldsets = [
        (None, {'fields': ('workout_session', 'exercise', 'sets', 'repetitions', 'weight')}),
    ]
    add_fieldsets = [
        (None, {
            'classes': ('wide',),
            'fields': ('workout_session', 'exercise', 'sets', 'repetitions', 'weight'),
        }),
    ]

admin.site.register(Exercise, ExerciseAdmin)
admin.site.register(WorkoutSession, WorkoutSessionAdmin)
admin.site.register(WorkoutSessionExercise, WorkoutSessionExerciseAdmin)

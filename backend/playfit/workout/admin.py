from django.contrib import admin
from .models import Exercise, WorkoutSession, WorkoutSessionExercise

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
        'workout_session', 'exercise', 'sets', 'repetitions', 'weight', 'difficulty'
    ]
    list_filter = [
        'workout_session', 'exercise', 'difficulty'
    ]
    fieldsets = [
        (None, {'fields': ('workout_session', 'exercise', 'sets', 'repetitions', 'weight', 'difficulty')}),
    ]
    add_fieldsets = [
        (None, {
            'classes': ('wide',),
            'fields': ('workout_session', 'exercise', 'sets', 'repetitions', 'weight', 'difficulty'),
        }),
    ]

admin.site.register(Exercise)
admin.site.register(WorkoutSession, WorkoutSessionAdmin)
admin.site.register(WorkoutSessionExercise, WorkoutSessionExerciseAdmin)

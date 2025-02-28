from django.urls import path
from .views import ExerciseView, WorkoutSessionView

urlpatterns = [
    path('get_exercises/', ExerciseView.as_view(), name='get_exercises'),
    path('add_exercise/', ExerciseView.as_view(), name='add_exercise'),
    path('get_workout_sessions/', WorkoutSessionView.as_view(), name='get_workout_sessions'),
    path('add_workout_session/', WorkoutSessionView.as_view(), name='add_workout_session'),
]

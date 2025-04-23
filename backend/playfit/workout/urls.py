from django.urls import path
from .views import ExerciseView, WorkoutSessionsView, WorkoutSessionExerciseView

urlpatterns = [
    path('get_exercises/', ExerciseView.as_view(), name='get_exercises'),
    path('add_exercise/', ExerciseView.as_view(), name='add_exercise'),
    path('get_workout_sessions/', WorkoutSessionsView.as_view(), name='get_workout_sessions'),
    path('add_workout_session/', WorkoutSessionsView.as_view(), name='add_workout_session'),
    path('update_workout_session/', WorkoutSessionsView.as_view(), name='update_workout_session'),
    path('get_workout_session_exercises/', WorkoutSessionExerciseView.as_view(), name='get_workout_session_exercises'),
]

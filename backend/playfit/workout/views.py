from django.utils.timezone import now
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from authentification.models import UserAchievement, UserProgress
from social.models import WorldPosition
from .models import WorkoutSession, Exercise, WorkoutSessionExercise
from .serializers import (
    WorkoutSessionSerializer,
    ExerciseSerializer,
    WorkoutSessionExerciseSerializer,
)

class ExerciseView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Get all exercises",
        manual_parameters=[
            openapi.Parameter(
                name="exercises",
                in_=openapi.IN_QUERY,
                type=openapi.TYPE_STRING,
                description="Filter exercises by name"
            )
        ],
        responses={
            200: openapi.Response("List of exercises", ExerciseSerializer(many=True)),
        }
    )
    def get(self, request):
        exercises: list[Exercise] = []

        if "exercises" in request.GET:
            exercise_names = request.GET["exercises"].split(",")
            for name in exercise_names:
                exercises += Exercise.objects.filter(name__icontains=name)
        else:
            exercises = Exercise.objects.all()

        return Response([{
            "name": exercise.name,
            "image": exercise.image.url if exercise.image else None,
        } for exercise in exercises], status=status.HTTP_200_OK)

    def post(self, request):
        if not request.user.is_staff:
            return Response("You are not authorized to add new exercises", status=status.HTTP_403_FORBIDDEN)

        exercise = Exercise.objects.create(
            name=request.data["name"],
            image=request.data["image"],
        )

        return Response({
            "name": exercise.name,
            "image": exercise.image.url if exercise.image else None,
        }, status=status.HTTP_201_CREATED)

class WorkoutSessionsView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Get all workout sessions",
        manual_parameters=[
            openapi.Parameter(
                name="date",
                in_=openapi.IN_QUERY,
                type=openapi.TYPE_STRING,
                description="Filter workout sessions by date"
            )
        ],
        responses={
            200: openapi.Response("List of workout sessions", WorkoutSessionSerializer(many=True)),
        }
    )
    def get(self, request):
        workout_sessions: list[WorkoutSession] = []

        if "date" in request.GET:
            workout_sessions = WorkoutSession.objects.filter(date=request.GET["date"])
        else:
            workout_sessions = WorkoutSession.objects.all()

        data = []
        for workout_session in workout_sessions:
            exercises = []
            workout_session_exercises = WorkoutSessionExercise.objects.filter(workout_session=workout_session)
            for workout_session_exercise in workout_session_exercises:
                exercises.append({
                    "name": workout_session_exercise.exercise.name,
                    "sets": workout_session_exercise.sets,
                    "repetitions": workout_session_exercise.repetitions,
                    "weight": workout_session_exercise.weight,
                    "difficulty": workout_session_exercise.difficulty,
                })
            data.append({
                "date": workout_session.creation_date,
                "duration": workout_session.duration,
                "exercises": exercises
            })

        return Response(data, status=status.HTTP_200_OK)

    @swagger_auto_schema(
        operation_description="Update a workout session",
        # request_body=WorkoutSessionPatchSerializer,
        responses={
            200: openapi.Response("Workout session updated successfully"),
            400: openapi.Response("Bad request, invalid data"),
            403: openapi.Response("Forbidden, you are not authorized to update this workout session"),
            404: openapi.Response("Not found, workout session not found")
        }
    )
    def patch(self, request):
        wp: WorldPosition = request.user.position
        workout_session: WorkoutSession = None

        try:
            if wp.is_in_city():
                workout_session = WorkoutSession.objects.get(user=request.user, city=wp.city, city_level=wp.city_level)
            elif wp.is_in_transition():
                workout_session = WorkoutSession.objects.get(user=request.user, transition_from=wp.transition_from, transition_to=wp.transition_to, transition_level=wp.transition_level)

        except WorkoutSession.DoesNotExist:
            return Response("Workout session not found", status=status.HTTP_404_NOT_FOUND)

        if workout_session is None:
            return Response("Workout session not found", status=status.HTTP_404_NOT_FOUND)

        workout_session.completed_date = now().date()
        workout_session.save()

        difficulty = request.data.get("difficulty")
        if difficulty is None:
            return Response("Difficulty not found", status=status.HTTP_400_BAD_REQUEST)

        if difficulty not in ["beginner", "intermediate", "advanced"]:
            return Response("Invalid difficulty", status=status.HTTP_400_BAD_REQUEST)

        workout_session_exercises = WorkoutSessionExercise.objects.filter(workout_session=workout_session).exclude(difficulty__in=difficulty)
        workout_session_exercises.delete()

        wp.move_to_next_level()

        # Update user progress
        user_progress = UserProgress.objects.get(user=request.user)
        user_progress.update_after_workout()

        # Retrieve all user achievements
        user_achievements = UserAchievement.objects.filter(user=request.user)

        # Check if the user has any achievements
        if user_achievements.exists():
            # If the user has achievements, update them
            for achievement in user_achievements:
                achievement.update_progress(workout_session)

        return Response("Workout session updated successfully", status=status.HTTP_200_OK)

class WorkoutSessionExerciseView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Get all workout session exercises",
        responses={
            200: openapi.Response("List of workout session exercises", WorkoutSessionExerciseSerializer(many=True)),
        }
    )
    def get(self, request):
        wp = request.user.position
        workout_session: WorkoutSession = None

        try:
            if wp.is_in_city():
                workout_session = WorkoutSession.objects.get(user=request.user, city=wp.city, city_level=wp.city_level)
            elif wp.is_in_transition():
                workout_session = WorkoutSession.objects.get(user=request.user, transition_from=wp.transition_from, transition_to=wp.transition_to, transition_level=wp.transition_level)

        except WorkoutSession.DoesNotExist:
            pass

        if workout_session is None:
            # Generate a new workout session, temporary solution
            workout_session = WorkoutSession.objects.create(
                user=request.user,
                city=wp.city if wp.is_in_city() else None,
                city_level=wp.city_level if wp.is_in_city() else None,
                transition_from=wp.transition_from if wp.is_in_transition() else None,
                transition_to=wp.transition_to if wp.is_in_transition() else None,
                creation_date=now().date(),
            )
            # Generate exercises for the workout session
            try:
                exercises = ['pushUp', 'squat', 'jumpingJack']
                for exercise in exercises:
                    WorkoutSessionExercise.objects.create(
                        workout_session=workout_session,
                        exercise=Exercise.objects.get(name=exercise),
                        sets=1,
                        repetitions=3 if exercise == 'pushUp' else 10 if exercise == 'squat' else 15,
                        weight=0,
                        difficulty="beginner",
                    )
                    WorkoutSessionExercise.objects.create(
                        workout_session=workout_session,
                        exercise=Exercise.objects.get(name=exercise),
                        sets=1,
                        repetitions=7 if exercise == 'pushUp' else 15 if exercise == 'squat' else 25,
                        weight=0,
                        difficulty="intermediate",
                    )
                    WorkoutSessionExercise.objects.create(
                        workout_session=workout_session,
                        exercise=Exercise.objects.get(name=exercise),
                        sets=1,
                        repetitions=15 if exercise == 'pushUp' else 30 if exercise == 'squat' else 50,
                        weight=0,
                        difficulty="advanced",
                    )
            except Exercise.DoesNotExist:
                return Response("Exercise not found", status=status.HTTP_404_NOT_FOUND)
            except Exception as e:
                return Response(f"Error generating workout session: {str(e)}", status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        workout_session_exercises = WorkoutSessionExercise.objects.filter(workout_session=workout_session)
        data = {
            'beginner': [],
            'intermediate': [],
            'advanced': []
        }

        for workout_session_exercise in workout_session_exercises:
            exercise = workout_session_exercise.exercise
            data[workout_session_exercise.difficulty].append({
                "name": exercise.name,
                "image": exercise.image.url,
                "sets": workout_session_exercise.sets,
                "repetitions": workout_session_exercise.repetitions,
                "weight": workout_session_exercise.weight,
            })

        return Response(data, status=status.HTTP_200_OK)

from rest_framework import status
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from .models import WorkoutSession, Exercise, WorkoutSessionExercise
from .serializers import WorkoutSessionSerializer, ExerciseSerializer, WorkoutSessionExerciseSerializer

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
            "description": exercise.description,
            "video_url": exercise.video_url,
            "difficulty": exercise.difficulty
        } for exercise in exercises], status=status.HTTP_200_OK)

    @swagger_auto_schema(
        operation_description="Add a new exercise",
        request_body=ExerciseSerializer,
        responses={
            201: openapi.Response("New exercise", ExerciseSerializer),
            403: openapi.Response("Forbidden", "You are not authorized to add new exercises")
        }
    )
    def post(self, request):
        if not request.user.is_staff:
            return Response("You are not authorized to add new exercises", status=status.HTTP_403_FORBIDDEN)

        exercise = Exercise.objects.create(
            name=request.data["name"],
            description=request.data["description"],
            video_url=request.data.get("video_url"),
            difficulty=request.data["difficulty"]
        )

        return Response({
            "name": exercise.name,
            "description": exercise.description,
            "video_url": exercise.video_url,
            "difficulty": exercise.difficulty
        }, status=status.HTTP_201_CREATED)

class WorkoutSessionView(APIView):
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
                    "weight": workout_session_exercise.weight
                })
            data.append({
                "date": workout_session.date,
                "duration": workout_session.duration,
                "exercises": exercises
            })

        return Response(data, status=status.HTTP_200_OK)

    @swagger_auto_schema(
        operation_description="Add a new workout session with its exercises for the current user",
        request_body=WorkoutSessionSerializer,
        responses={
            201: openapi.Response("New workout session", "Workout session added successfully"),
            400: openapi.Response("Bad request", "Invalid workout session data")
        }
    )
    def post(self, request):
        workout_session_serializer = WorkoutSessionSerializer(data={
            "date": request.data["date"],
            "duration": request.data["duration"]
        })

        if not workout_session_serializer.is_valid():
            return Response(workout_session_serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        workout_session = workout_session_serializer.save(user=request.user)

        if "exercises" not in request.data or not isinstance(request.data["exercises"], list) or len(request.data["exercises"]) == 0:
            workout_session.delete()
            return Response("Invalid workout session data", status=status.HTTP_400_BAD_REQUEST)

        for exercise in request.data["exercises"]:
            try:
                exercise_obj = Exercise.objects.get(name=exercise["name"])
            except Exercise.DoesNotExist:
                workout_session.delete()
                return Response(f"Exercise {exercise['name']} does not exist.", status=status.HTTP_400_BAD_REQUEST)

            exercise_serializer = WorkoutSessionExerciseSerializer(data={
                "workout_session": workout_session.id,
                "exercise": exercise_obj.id,
                "sets": exercise["sets"],
                "repetitions": exercise["repetitions"],
                "weight": exercise.get("weight")
            })

            if not exercise_serializer.is_valid():
                workout_session.delete()
                return Response(exercise_serializer.errors, status=status.HTTP_400_BAD_REQUEST)
            if not Exercise.objects.filter(name=exercise["name"]).exists():
                workout_session.delete()
                return Response(f"Exercise {exercise['name']} does not exist.", status=status.HTTP_400_BAD_REQUEST)

            exercise_serializer.save()

        return Response("Workout session added successfully", status=status.HTTP_201_CREATED)

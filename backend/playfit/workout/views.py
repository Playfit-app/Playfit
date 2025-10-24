from django.utils.timezone import now
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi
from authentification.models import UserAchievement, UserProgress
from social.models import WorldPosition, Notification, Post
from social.utils import send_notification
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
            workout_sessions = WorkoutSession.objects.filter(creation_date=request.GET["date"])
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
                workout_session = WorkoutSession.objects.get(user=request.user, transition_from=wp.transition_from, transition_to=wp.transition_to)

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

        # Create a post for the workout session
        post = Post.objects.create(
            user=request.user,
            content=f"I just completed level {wp.city_level} workout session in {wp.city.name if wp.is_in_city() else f'transition from {wp.transition_from.name} to {wp.transition_to.name}'} with difficulty {difficulty}!",
        )

        # Send notification to the followers of the user
        followers = list(request.user.get_followers())
        notifications = [
            Notification(
                user=follower,
                sender=request.user,
                notification_type="post",
                post=post,
            )
            for follower in followers
        ]
        Notification.objects.bulk_create(notifications)
        for follower in followers:
            send_notification(follower, {
                'id': notifications[followers.index(follower)].id,
                'sender': request.user.username,
                'notification_type': notifications[followers.index(follower)].notification_type,
                'created_at': notifications[followers.index(follower)].created_at.isoformat(),
                'post': post.id,
                'seen': notifications[followers.index(follower)].seen,
            })

        return Response("Workout session updated successfully", status=status.HTTP_200_OK)


def generate_workout_exercises(user, workout_session):
    # Define available exercises pool
    # For now, using core 3 exercises across all fitness levels
    EXERCISE_POOLS = {
        'beginner': ['pushUp', 'squat', 'jumpingJack'],
        'intermediate': ['pushUp', 'squat', 'jumpingJack'],
        'advanced': ['pushUp', 'squat', 'jumpingJack']
    }
    
    # Default repetitions for first session (core 3 exercises only)
    DEFAULT_REPS = {
        'beginner': {
            'pushUp': 5,
            'squat': 10,
            'jumpingJack': 15
        },
        'intermediate': {
            'pushUp': 10,
            'squat': 15,
            'jumpingJack': 25
        },
        'advanced': {
            'pushUp': 15,
            'squat': 25,
            'jumpingJack': 40
        }
    }
    
    # Get user's fitness level
    fitness_level = user.fitness_level
    
    # Get the appropriate exercise pool
    exercise_names = EXERCISE_POOLS.get(fitness_level, EXERCISE_POOLS['beginner'])
    
    # Generate exercises for each difficulty level
    for difficulty in ['beginner', 'intermediate', 'advanced']:
        # For now, all difficulty levels use the same 3 core exercises
        # TODO: When more exercises are added, use different counts:
        # beginner: 3, intermediate: 4, advanced: 5
        selected_exercises = exercise_names  # Use all available exercises (currently 3)
        
        for exercise_name in selected_exercises:
            try:
                exercise = Exercise.objects.get(name__iexact=exercise_name)
            except Exercise.DoesNotExist:
                # Return None to signal that a required exercise is missing
                return None
            
            # Get the last 3-5 performances for this specific exercise and difficulty
            recent_performances = WorkoutSessionExercise.objects.filter(
                workout_session__user=user,
                workout_session__completed_date__isnull=False,
                exercise=exercise,
                difficulty=difficulty
            ).order_by('-workout_session__completed_date')[:5]  # Get up to 5 most recent
            
            # Determine repetitions based on past performance
            if recent_performances.exists():
                # User has completed this exercise before at this difficulty
                performances_list = list(recent_performances)
                total_reps = sum(perf.repetitions for perf in performances_list)
                avg_reps = total_reps / len(performances_list)
                
                # Analyze performance trend to determine progression rate
                performance_trend = 0.0
                if len(performances_list) >= 2:
                    recent_avg = sum(p.repetitions for p in performances_list[:2]) / 2
                    older_avg = sum(p.repetitions for p in performances_list[2:]) / len(performances_list[2:]) if len(performances_list) > 2 else recent_avg
                    performance_trend = (recent_avg - older_avg) / older_avg if older_avg > 0 else 0.0
                
                # Determine base progression rate based on rep range
                if avg_reps <= 5:
                    base_rate = 0.20  # 20% for very low reps
                elif avg_reps <= 10:
                    base_rate = 0.15  # 15% for low reps
                elif avg_reps <= 20:
                    base_rate = 0.10  # 10% for medium reps
                else:
                    base_rate = 0.05  # 5% for high reps
                
                # Adjust progression rate based on performance trend
                if performance_trend > 0.10:
                    adjusted_rate = base_rate * 1.5
                elif performance_trend > 0.05:
                    adjusted_rate = base_rate * 1.25
                elif performance_trend < -0.05:
                    adjusted_rate = base_rate * 0.7
                elif performance_trend < 0:
                    adjusted_rate = base_rate * 0.85
                else:
                    adjusted_rate = base_rate
                
                # Apply the adjusted progression rate
                repetitions = int(avg_reps * (1 + adjusted_rate))
                
                # Ensure at least +1 rep progression (unless declining)
                if repetitions == int(avg_reps) and performance_trend >= 0:
                    repetitions = int(avg_reps) + 1
                elif repetitions < int(avg_reps):
                    repetitions = int(avg_reps)
            else:
                # First time doing this exercise at this difficulty - use defaults
                repetitions = DEFAULT_REPS[difficulty].get(exercise_name, 10)
            
            # Create the workout session exercise
            WorkoutSessionExercise.objects.create(
                workout_session=workout_session,
                exercise=exercise,
                sets=1,
                repetitions=repetitions,
                weight=0,
                difficulty=difficulty,
            )
    
    # Return True to signal successful generation
    return True


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
                workout_session = WorkoutSession.objects.get(user=request.user, transition_from=wp.transition_from, transition_to=wp.transition_to)

        except WorkoutSession.DoesNotExist:
            pass

        if workout_session is None:
            # Generate a new workout session
            workout_session = WorkoutSession.objects.create(
                user=request.user,
                city=wp.city if wp.is_in_city() else None,
                city_level=wp.city_level if wp.is_in_city() else None,
                transition_from=wp.transition_from if wp.is_in_transition() else None,
                transition_to=wp.transition_to if wp.is_in_transition() else None,
                creation_date=now().date(),
            )
            
            # Generate exercises using the intelligent algorithm
            result = generate_workout_exercises(request.user, workout_session)
            if result is None:
                # One or more required exercises are missing from the database
                workout_session.delete()  # Clean up the created session
                return Response("Exercise not found. Please ensure all required exercises exist in the database.", status=status.HTTP_404_NOT_FOUND)

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
                "image": exercise.image.url if exercise.image else None,
                "sets": workout_session_exercise.sets,
                "repetitions": workout_session_exercise.repetitions,
                "weight": workout_session_exercise.weight,
            })

        return Response(data, status=status.HTTP_200_OK)

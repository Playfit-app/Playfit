import datetime
from rest_framework import serializers
from .models import Exercise, WorkoutSession, WorkoutSessionExercise

class ExerciseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Exercise
        fields = '__all__'

    def validate(self, data):
        if data['difficulty'] not in ['beginner', 'intermediate', 'advanced']:
            raise serializers.ValidationError("Invalid difficulty level.")
        if len(data['name']) > 30:
            raise serializers.ValidationError("Name must be less than 30 characters.")
        return data

class WorkoutSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutSession
        fields = ['date', 'duration']

    def validate(self, data):
        if data['date'] > datetime.date.today():
            raise serializers.ValidationError("Invalid date.")
        return data

    def save(self, user):
        workout_session = WorkoutSession.objects.create(
            user=user,
            date=self.validated_data['date'],
            duration=self.validated_data['duration']
        )
        return workout_session

class WorkoutSessionExerciseSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutSessionExercise
        fields = '__all__'

    def validate(self, data):
        if data['sets'] <= 0:
            raise serializers.ValidationError("Invalid number of sets.")
        if data['repetitions'] <= 0:
            raise serializers.ValidationError("Invalid number of repetitions.")
        if data['exercise'].difficulty == 'beginner' and data['weight']:
            raise serializers.ValidationError("Beginner exercises should not have weight.")
        if data['exercise'].difficulty != 'beginner' and data['weight'] <= 0:
            raise serializers.ValidationError("Invalid weight.")
        return data

    def save(self):
        workout_session_exercise = WorkoutSessionExercise.objects.create(
            workout_session=self.validated_data['workout_session'],
            exercise=self.validated_data['exercise'],
            sets=self.validated_data['sets'],
            repetitions=self.validated_data['repetitions'],
            weight=self.validated_data.get('weight')
        )
        return workout_session_exercise

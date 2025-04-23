import datetime
from rest_framework import serializers
from .models import Exercise, WorkoutSession, WorkoutSessionExercise

class ExerciseSerializer(serializers.ModelSerializer):
    class Meta:
        model = Exercise
        fields = '__all__'

    def validate(self, data):
        if data['difficulty'] not in ['beginner', 'intermediate', 'advanced']:
            raise serializers.ValidationError({"difficulty": "Invalid difficulty."})
        if len(data['name']) > 30:
            raise serializers.ValidationError({"name": "Name is too long."})
        return data

class WorkoutSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutSession
        fields = ['creation_date', 'duration']

    def validate(self, data):
        if data['creation_date'] > datetime.date.today():
            raise serializers.ValidationError({"creation_date": "Invalid date."})
        if data['duration'] <= datetime.timedelta(minutes=0):
            raise serializers.ValidationError({"duration": "Invalid duration."})
        return data

    def save(self, user):
        workout_session = WorkoutSession.objects.create(
            user=user,
            date=self.validated_data['date'],
            duration=self.validated_data['duration']
        )
        return workout_session

class WorkoutSessionPatchSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutSession
        fields = ['completed', 'selected_difficulty']
    completed = serializers.BooleanField(required=False)
    selected_difficulty = serializers.ListField(
        child=serializers.ChoiceField(choices=WorkoutSessionExercise.DIFFICULTY_CHOICES),
        required=False
    )

class WorkoutSessionExerciseSerializer(serializers.ModelSerializer):
    class Meta:
        model = WorkoutSessionExercise
        fields = '__all__'

    def validate(self, data):
        if data['sets'] <= 0:
            raise serializers.ValidationError({"sets": "Invalid number of sets."})
        if data['repetitions'] <= 0:
            raise serializers.ValidationError({"repetitions": "Invalid number of repetitions."})
        if data['workout_session'].difficulty == 'beginner' and ('weight' in data and data['weight'] is not None and data['weight'] > 0):
            raise serializers.ValidationError({"weight": "Beginner exercises should not have weight."})
        if data['workout_session'].difficulty != 'beginner' and ('weight' not in data or data['weight'] is None or data['weight'] <= 0):
            raise serializers.ValidationError({"weight": "Invalid weight."})
        if data['workout_session'].completed_date is not None:
            raise serializers.ValidationError({"workout_session": "Workout session is already completed."})
        if data['workout_session'].user != self.context['request'].user:
            raise serializers.ValidationError({"workout_session": "User does not match."})
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

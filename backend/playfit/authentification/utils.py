import random
import requests
import base64
import struct

from .models import CustomUser, UserAchievement, GameAchievement
from django.utils import timezone
from rest_framework.response import Response
from rest_framework import status

def generate_username_with_number(base_name: str) -> str:
    base_name = base_name.replace(" ", "").lower()

    while True:
        random_number = str(random.randint(10000, 9999999))
        potential_username = f"{base_name}_{random_number}"

        if not CustomUser.objects.filter(username=potential_username).exists():
            return potential_username


def get_user_birthdate(access_token: str) -> str:
    url = 'https://people.googleapis.com/v1/people/me?personFields=birthdays'
    headers = {
        'Authorization': f'Bearer {access_token}',
    }
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        user_data = response.json()
        if 'birthdays' in user_data:
            for birthday in user_data['birthdays']:
                if 'date' in birthday and 'year' in birthday['date'] and 'month' in birthday['date'] and 'day' in birthday['date']:
                    birth_date = f"{birthday['date']['year']}-{birthday['date']['month']:02}-{birthday['date']['day']:02}"
                    return birth_date
    return None

def generate_uid_from_id(id: int) -> str:
    return base64.urlsafe_b64encode(struct.pack("I", id)).decode().rstrip("=")

def get_id_from_uid(uid: str) -> int:
    return struct.unpack("I", base64.urlsafe_b64decode(uid + "=="))[0]

def evaluate_achievements(user, achievement_to_update):
    # Check if the user has the achievement
    try:
        user_achievement = UserAchievement.objects.get(user=user, achievement=achievement_to_update)
    except UserAchievement.DoesNotExist:
        return Response({'message': 'User achievement not found'}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        game_achievement = GameAchievement.objects.get(id=achievement_to_update.id)
    except GameAchievement.DoesNotExist:
        return Response({'message': 'Game achievement not found'}, status=status.HTTP_400_BAD_REQUEST)

    # Check if the achievement is completed
    if user_achievement.is_completed:
        return Response({'message': 'Achievement already completed'}, status=status.HTTP_400_BAD_REQUEST)
    for criteria in game_achievement.criteria:
        for key, value in criteria.items():
            if key in user_achievement.progress:
                if user_achievement.progress[key] >= value:
                    user_achievement.is_completed = True
                    user_achievement.awarded_at = timezone.now()
                    user_achievement.save()
                    return Response({'message': 'Achievement completed'}, status=status.HTTP_200_OK)
                user_achievement.progress[key] += value
    user_achievement.save()
    return Response({'message': 'Achievement progress updated'}, status=status.HTTP_200_OK)

#Create the GameAchievement
def create_game_achievement(name_achievement, description_achievement, criteria_achievement, xp_reward_achievement):
    # Check if the achievement already exists
    if GameAchievement.objects.filter(name=name_achievement).exists():
        return Response({'message': 'Achievement already exists'}, status=status.HTTP_400_BAD_REQUEST)

    # Create the achievement
    new_achievement = GameAchievement.objects.create(
        name=name_achievement,
        description=description_achievement,
        criteria=criteria_achievement,
        xp_reward_achievement=xp_reward_achievement,
    )
    return Response({'message': 'Achievement created successfully'}, status=status.HTTP_201_CREATED)

def setup_game_achievements():
    # Define the achievements
    achievements = [
        {
            "name": "Welcome to Playfit",
            "description": "Welcome to Playfit! We are happy to have you here.",
            "criteria": [{"current_streak": 1}],
            "xp_reward": 50,
        },
        {
            "name": "First Steps",
            "description": "Complete your first workout.",
            "criteria": [{"workouts_completed": 1}],
            "xp_reward": 100,
        },
        {
            "name": "The beginning of a journey",
            "description": "Complete 5 workouts.",
            "criteria": [{"workouts_completed": 5}],
            "xp_reward": 150,
        },
        {
            "name": "Regularity is THE key, week 1",
            "description": "The current streak is 7 days.",
            "criteria": [{"current_streak": 7}],
            "xp_reward": 150,
        },
        {
            "name": "Regularity is THE key, week 2",
            "description": "The current streak is 14 days.",
            "criteria": [{"current_streak": 14}],
            "xp_reward": 200,
        },
        {
            "name": "Regularity is THE key, week 3",
            "description": "The current streak is 21 days.",
            "criteria": [{"current_streak": 21}],
            "xp_reward": 250,
        },
        {
            "name": "Regularity is THE key, month 1",
            "description": "The current streak is 30 days.",
            "criteria": [{"current_streak": 30}],
            "xp_reward": 300,
        },
    ]

    # Create the achievements
    for achievement in achievements:
        create_game_achievement(
            achievement["name"],
            achievement["description"],
            achievement["criteria"],
            achievement["xp_reward"],
        )
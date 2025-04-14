import random
import requests
import base64
import struct
from django.utils import timezone
from rest_framework.response import Response
from rest_framework import status
from social.models import WorldPosition
from .models import CustomUser, UserAchievement, GameAchievement

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

def evaluate_achievements(user, progress):
    # Get all achievements
    achievements = GameAchievement.objects.all()

    for achievement in achievements:
        for criterias in achievement.criteria:
            for key, value in criterias.items():
                if key in progress:
                    user_achievement = UserAchievement.objects.get(user=user, achievement=achievement)
                    if user_achievement.is_completed:
                        continue
                    if key == 'current_streak':
                        if progress[key] >= value:
                            user_achievement.is_completed = True
                            user_achievement.awarded_at = timezone.now()
                            user_achievement.save()
                            # Add XP reward to the user
                            # user.xp += achievement.xp_reward
                            # user.save()
                    else:
                        if progress[key] >= value:
                            user_achievement.progress[key] = progress[key]
                            user_achievement.save()
    
    return Response({'message': 'Achievement progress updated'}, status=status.HTTP_200_OK)

def link_achievements_to_user(user):
    # Get all achievements
    achievements = GameAchievement.objects.all()

    # Check if the user already has the achievement
    for achievement in achievements:
        UserAchievement.objects.get_or_create(user=user, achievement=achievement)

def get_position_data(data: WorldPosition) -> dict:
    if data.is_in_city():
        return {
            'status': 'in_city',
            'continent': data.city.country.continent.name,
            'country': data.city.country.name,
            'city': data.city.name,
            'level': data.city_level,
        }
    elif data.is_in_transition():
        return {
            'status': 'in_transition',
            'continent': data.transition_from.country.continent.name,
            'country': data.transition_from.country.name,
            'from': data.transition_from.name,
            'to': data.transition_to.name,
            'level': data.transition_level,
        }
    return {'status': 'unknown'}

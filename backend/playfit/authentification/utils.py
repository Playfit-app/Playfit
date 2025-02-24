import random
import requests
import base64
import struct

from .models import CustomUser

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

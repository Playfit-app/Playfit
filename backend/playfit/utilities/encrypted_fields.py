import hashlib
from django.db import models
from django.conf import settings
from cryptography.fernet import Fernet

def hash(string: str) -> str:
    normalized_string = string.strip().lower().encode()
    return hashlib.sha256(normalized_string).hexdigest()

def get_fernet():
    key = settings.CRYPTOGRAPHY_KEY

    if not key:
        raise ValueError("CRYPTOGRAPHY_KEY is not set")
    return Fernet(key)

class EncryptedField(models.Field):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def from_db_value(self, value, expression, connection):
        if value is None:
            return value
        return self.decrypt(value)

    def get_prep_value(self, value):
        if value is None:
            return value
        return self.encrypt(value)

    def to_python(self, value):
        if isinstance(value, str) and value.startswith("gAAAAA"):
            return self.decrypt(value)
        return value

    def encrypt(self, value):
        return get_fernet().encrypt(value.encode()).decode()

    def decrypt(self, value):
        return get_fernet().decrypt(value.encode()).decode()

class EncryptedCharField(EncryptedField, models.CharField):
    pass

class EncryptedTextField(EncryptedField, models.TextField):
    pass

class EncryptedEmailField(EncryptedField, models.EmailField):
    pass

class EncryptedDateField(EncryptedField, models.CharField):
    pass

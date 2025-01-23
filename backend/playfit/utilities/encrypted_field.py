import base64
from django.db import models
from cryptography.fernet import Fernet
from django.conf import settings

def get_fernet():
    key = settings.CRYPTOGRAPHY_KEY or settings.SECRET_KEY

    if len(key) < 32:
        raise ValueError("The key must be at least 32 bytes long.")
    key = base64.urlsafe_b64encode(key[:32].encode())
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

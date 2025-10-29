from django.test import override_settings
from rest_framework.test import APITestCase
from .utils import TempMediaMixin

FAST_SETTINGS = dict(
    PASSWORD_HASHERS=["django.contrib.auth.hashers.MD5PasswordHasher"],
    EMAIL_BACKEND="django.core.mail.backends.locmem.EmailBackend",
    CACHES={"default": {"BACKEND": "django.core.cache.backends.locmem.LocMemCache"}},
)

@override_settings(**FAST_SETTINGS)
class FastAPITestCase(APITestCase):
    """APITestCase with faster password hashing, email, and cache."""
    pass

class BaseAPITestCase(TempMediaMixin, FastAPITestCase):
    """Default base for all API tests in the project."""
    pass

"""
ASGI config for playfit project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.1/howto/deployment/asgi/
"""

import os
import django
from django.core.asgi import get_asgi_application
from django.contrib.staticfiles.handlers import ASGIStaticFilesHandler
from channels.routing import ProtocolTypeRouter, URLRouter

django.setup()

from social.routing import websocket_urlpatterns  # noqa: E402
from social.middleware import TokenAuthMiddleware # noqa: E402

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'playfit.settings')

application = ProtocolTypeRouter({
    "http": ASGIStaticFilesHandler(get_asgi_application()),
    "websocket": TokenAuthMiddleware(
        URLRouter(
            websocket_urlpatterns
        )
    ),
})

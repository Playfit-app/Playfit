from django.contrib.auth.models import AnonymousUser
from django.db import close_old_connections
from rest_framework.authtoken.models import Token
from channels.middleware import BaseMiddleware
from asgiref.sync import sync_to_async
import logging

logger = logging.getLogger(__name__)

@sync_to_async
def get_user_from_token(token_key):
    try:
        token = Token.objects.get(key=token_key)
        return token.user
    except Token.DoesNotExist:
        return AnonymousUser()

class TokenAuthMiddleware(BaseMiddleware):
    async def __call__(self, scope, receive, send):
        headers = dict(scope.get("headers", []))
        auth_header = headers.get(b"authorization", None)

        if auth_header:
            try:
                token_name, token_key = auth_header.decode().split()
                if token_name == "Token":
                    scope["user"] = await get_user_from_token(token_key)
            except ValueError:
                scope["user"] = AnonymousUser()
        else:
            scope["user"] = AnonymousUser()

        close_old_connections()
        return await super().__call__(scope, receive, send)

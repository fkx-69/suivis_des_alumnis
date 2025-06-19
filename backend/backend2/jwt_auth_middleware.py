from urllib.parse import parse_qs

from django.contrib.auth.models import AnonymousUser
from django.db import close_old_connections
from rest_framework_simplejwt.authentication import JWTAuthentication
from channels.db import database_sync_to_async

class JWTAuthMiddleware:
    """Custom middleware that authenticates a user using a JWT token."""

    def __init__(self, inner):
        self.inner = inner
        self.jwt_auth = JWTAuthentication()

    async def __call__(self, scope, receive, send):
        close_old_connections()
        headers = dict(scope.get("headers", []))
        token = None

        # Look for token in Authorization header
        auth_header = headers.get(b"authorization")
        if auth_header:
            auth_header = auth_header.decode()
            if auth_header.startswith("Bearer "):
                token = auth_header[7:]

        # Fallback to token passed as query parameter
        if token is None:
            query_string = scope.get("query_string", b"" ).decode()
            query_params = parse_qs(query_string)
            token = query_params.get("token", [None])[0]

        if token:
            try:
                validated = self.jwt_auth.get_validated_token(token)
                user = await database_sync_to_async(self.jwt_auth.get_user)(validated)
                scope["user"] = user
            except Exception:
                scope["user"] = AnonymousUser()
        else:
            scope.setdefault("user", AnonymousUser())

        return await self.inner(scope, receive, send)


def JWTAuthMiddlewareStack(inner):
    from channels.auth import AuthMiddlewareStack

    return AuthMiddlewareStack(JWTAuthMiddleware(inner))

"""
ASGI config for backend2 project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.2/howto/deployment/asgi/
"""

import os
from channels.routing import ProtocolTypeRouter, URLRouter
from .jwt_auth_middleware import JWTAuthMiddlewareStack
from django.core.asgi import get_asgi_application
import notifications.routing
import messaging.routing


os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend2.settings')

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": JWTAuthMiddlewareStack(
        URLRouter(
            notifications.routing.websocket_urlpatterns
            + messaging.routing.websocket_urlpatterns
        )
    ),
})

"""
ASGI config for backend2 project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.2/howto/deployment/asgi/
"""

import os
import django
from channels.routing import ProtocolTypeRouter, URLRouter
from .jwt_auth_middleware import JWTAuthMiddlewareStack
from django.core.asgi import get_asgi_application
from notifications.routing import websocket_urlpatterns  
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend2.settings') 
django.setup()

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": JWTAuthMiddlewareStack(
        URLRouter(
            websocket_urlpatterns
        )
    ),
})


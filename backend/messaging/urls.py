from django.urls import path
from .views import (
    EnvoyerMessagePriveView,
    MessagesRecusView,
    MessagesEnvoyesView,
    
)

urlpatterns = [
    path('envoyer/', EnvoyerMessagePriveView.as_view(), name='envoyer_message'),
    path('recus/', MessagesRecusView.as_view(), name='messages_recus'),
    path('envoyes/', MessagesEnvoyesView.as_view(), name='messages_envoyes'),
]

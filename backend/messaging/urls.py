from django.urls import path
from .views import (
    EnvoyerMessagePriveView,
    MessagesRecusView,
    MessagesEnvoyesView,
    ConversationsListView,
    MessagesWithUserView,
)

urlpatterns = [
    path('envoyer/', EnvoyerMessagePriveView.as_view(), name='envoyer_message'),
    path('recus/', MessagesRecusView.as_view(), name='messages_recus'),
    path('envoyes/', MessagesEnvoyesView.as_view(), name='messages_envoyes'),
    path('conversations/', ConversationsListView.as_view(), name='conversations'),
    path('with/<str:username>/', MessagesWithUserView.as_view(), name='messages_with_user'),
]

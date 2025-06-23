from django.urls import path
from .views import (
    EnvoyerMessagePriveView,
    MessagesRecusView,
    MessagesEnvoyesView,
    MessagesAvecUtilisateurView,
    ConversationsListView,
    
)

urlpatterns = [
    path('envoyer/', EnvoyerMessagePriveView.as_view(), name='envoyer_message'),
    path('recus/', MessagesRecusView.as_view(), name='messages_recus'),
    path('envoyes/', MessagesEnvoyesView.as_view(), name='messages_envoyes'),
    path('with/<str:username>/', MessagesAvecUtilisateurView.as_view(), name='messages_avec_utilisateur'),
    path('conversations/', ConversationsListView.as_view(), name='conversations_liste'),
]

from django.urls import path
from .views import (
    GroupeCreateView,
    RejoindreGroupeView,
    QuitterGroupeView,
    ListeMembresView,
    EnvoyerMessageView
)

urlpatterns = [
    path('creer/', GroupeCreateView.as_view(), name='creer-groupe'),
    path('<str:nom_groupe>/rejoindre/', RejoindreGroupeView.as_view(), name='rejoindre-groupe'),
    path('<str:nom_groupe>/quitter/', QuitterGroupeView.as_view(), name='quitter-groupe'),
    path('<str:nom_groupe>/membres/', ListeMembresView.as_view(), name='liste-membres'),
    path('<str:nom_groupe>/envoyer-message/', EnvoyerMessageView.as_view(), name='envoyer-message'),
]

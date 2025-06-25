from django.urls import path
from .views import (
    GroupeCreateView,
    RejoindreGroupeView,
    QuitterGroupeView,
    ListeMembresView,
    EnvoyerMessageView,
    ListeMessagesView,
    ListeGroupesView,
    MesGroupesView
)

urlpatterns = [
    path('creer/', GroupeCreateView.as_view(), name='creer-groupe'),
    path('listes/', ListeGroupesView.as_view(), name='liste-groupes'),
    path('mes-groupes/', MesGroupesView.as_view(), name='mes-groupes'),
    path('<int:groupe_id>/rejoindre/', RejoindreGroupeView.as_view(), name='rejoindre-groupe'),
    path('<int:groupe_id>/quitter/', QuitterGroupeView.as_view(), name='quitter-groupe'),
    path('<int:groupe_id>/membres/', ListeMembresView.as_view(), name='liste-membres'),
    path('<int:groupe_id>/envoyer-message/', EnvoyerMessageView.as_view(), name='envoyer-message'),
    path('<int:groupe_id>/messages/', ListeMessagesView.as_view(), name='liste-messages'),
    
]

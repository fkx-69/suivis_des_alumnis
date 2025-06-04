from django.urls import path
from .views import (
    EnvoyerDemandeView,
    MesDemandesView,
    RepondreDemandeView,
    SupprimerDemandeView,
)

urlpatterns = [
    path('envoyer/', EnvoyerDemandeView.as_view(), name='envoyer-demande'),
    path('mes-demandes/', MesDemandesView.as_view(), name='mes-demandes'),
    path('repondre/<int:pk>/', RepondreDemandeView.as_view(), name='repondre-demande'),
    path('supprimer/<int:pk>/', SupprimerDemandeView.as_view(), name='supprimer-demande'),
]

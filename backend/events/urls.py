from django.urls import path
from .views import (
    CreateEvenementView,
    ModifierEvenementView,
    ValiderEvenementView,
    SupprimerEvenementView,
    ListeEvenementsVisiblesView,
    MesEvenementsView,
    MesEvenementsNonValidésView
)

urlpatterns = [
    path('evenements/creer/', CreateEvenementView.as_view(), name='creer-evenement'),
    path('evenements/<int:pk>/modifier/', ModifierEvenementView.as_view(), name='modifier-evenement'),
    path('evenements/<int:pk>/supprimer/', SupprimerEvenementView.as_view(), name='supprimer-evenement'),
    path('evenements/<int:pk>/valider/', ValiderEvenementView.as_view(), name='valider-evenement'),
    path('evenements/', ListeEvenementsVisiblesView.as_view(), name='evenements-visibles'),
    path('evenements/mes/', MesEvenementsView.as_view(), name='mes-evenements'),
    path('mes-evenements-en-attente/', MesEvenementsNonValidésView.as_view(), name='mes-evenements-en-attente'),
]



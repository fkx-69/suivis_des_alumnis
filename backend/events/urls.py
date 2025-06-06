from django.urls import path
from .views import (
    CreateEvenementView,
    ModifierEvenementView,
    ValiderEvenementView,
    ListeEvenementsVisiblesView,
    SupprimerEvenementView
)

urlpatterns = [
    path('creer/', CreateEvenementView.as_view(), name='creer-evenement'),
    path('<int:pk>/modifier/', ModifierEvenementView.as_view(), name='modifier-evenement'),
    path('<int:pk>/valider/', ValiderEvenementView.as_view(), name='valider-evenement'),
    path('calendrier/', ListeEvenementsVisiblesView.as_view(), name='evenements-visibles'),
    path('evenements/<int:pk>/supprimer/', SupprimerEvenementView.as_view(), name='supprimer-evenement'),

]
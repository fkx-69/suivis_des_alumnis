from django.urls import path
from .views import SituationProStatsView, DomaineStatsParFiliereView

urlpatterns = [
    path('situation/', SituationProStatsView.as_view(), name='situation-pro-stats'),
    path('domaines/<int:filiere_id>/', DomaineStatsParFiliereView.as_view(), name='domaines-par-filiere'),
]

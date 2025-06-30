from django.urls import path
from .views import SoumettreEnqueteAPIView,LancerEnvoiEnqueteAPIView

urlpatterns = [
    path('repondre/', SoumettreEnqueteAPIView.as_view(), name='soumettre-enquete'),
    path('lancer-enquete/', LancerEnvoiEnqueteAPIView.as_view(), name='lancer-enquete'),
]

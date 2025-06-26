from django.urls import path
from .views import LancerEnqueteView

urlpatterns = [
    path('lancer-enquete/', LancerEnqueteView.as_view(), name='lancer-enquete'),
]

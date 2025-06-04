from django.urls import path
from .views import ListeNotificationsView

urlpatterns = [
    path('', ListeNotificationsView.as_view(), name='liste_notifications'),
]

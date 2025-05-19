from django.urls import path
from .views import FiliereListCreateView, FiliereDeleteView

urlpatterns = [
    path('', FiliereListCreateView.as_view(), name='filiere-list-create'),
    path('<int:pk>/', FiliereDeleteView.as_view(), name='filiere-delete'),
]
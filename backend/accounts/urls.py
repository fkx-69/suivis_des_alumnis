from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    LoginAPIView, MeAPIView, UpdateProfileAPIView,
    RegisterEtudiantAPIView, RegisterAlumniAPIView,
    ListEtudiantsAPIView, ListAlumnisAPIView,
    ParcoursAcademiqueViewSet,ParcoursProfessionnelViewSet, ChangePasswordAPIView, ChangeEmailAPIView,UserSearchView
    , EtudiantSearchView, AlumniSearchView)

router = DefaultRouter()
router.register(r'parcours-academiques', ParcoursAcademiqueViewSet, basename='parcours-academique')
router.register(r'parcours-professionnels', ParcoursProfessionnelViewSet, basename='parcours-professionnel')


urlpatterns = [
    path('login/', LoginAPIView.as_view(), name='login'),
    path('me/', MeAPIView.as_view(), name='me'),
    path('me/update/', UpdateProfileAPIView.as_view(), name='update-profile'),
    path('change-password/', ChangePasswordAPIView.as_view(), name='change-password'),
    path('change-email/', ChangeEmailAPIView.as_view(), name='change-email'),
    path('register/etudiant/', RegisterEtudiantAPIView.as_view(), name='register-etudiant'),
    path('register/alumni/', RegisterAlumniAPIView.as_view(), name='register-alumni'),
    path('etudiants/', ListEtudiantsAPIView.as_view(), name='list-etudiants'),
    path('alumnis/', ListAlumnisAPIView.as_view(), name='list-alumnis'),
    path('rechercher-utilisateur/', UserSearchView.as_view(), name='rechercher_utilisateur'),
    path('rechercher-etudiants/', EtudiantSearchView.as_view(), name='rechercher_etudiants'),
    path('rechercher-alumnis/', AlumniSearchView.as_view(), name='rechercher_alumnis'),
    path('', include(router.urls)),
] 

from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    LoginAPIView, MeAPIView, UpdateProfileAPIView,
    RegisterEtudiantAPIView, RegisterAlumniAPIView,
    ListEtudiantsAPIView, ListAlumnisAPIView,
    ParcoursAcademiqueViewSet,ParcoursProfessionnelViewSet, ChangePasswordAPIView, ChangeEmailAPIView,SearchUserView
    ,SuggestionsView,PublicUserRetrieveAPIView, PublicAlumniProfileAPIView,PostesParSecteurAPIView,PublicParcoursAcademiqueView, PublicParcoursProfessionnelView)

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
    path('search/', SearchUserView.as_view(), name='search-users'),
    path('suggestions/', SuggestionsView.as_view(), name='suggestions-users'),
    path('postes-par-secteur/', PostesParSecteurAPIView.as_view(), name='postes-par-secteur'),
    path('parcours-academiques/alumni/<int:alumni_id>/', PublicParcoursAcademiqueView.as_view(), name='public-parcours-academiques'),
    path('parcours-professionnels/alumni/<int:alumni_id>/', PublicParcoursProfessionnelView.as_view(), name='public-parcours-professionnels'),
    path('', include(router.urls)),
    path('<str:username>/', PublicUserRetrieveAPIView.as_view(), name='public-user-profile'),
    path('alumni/public/<int:id>/', PublicAlumniProfileAPIView.as_view(), name='public_alumni_profile'),

] 
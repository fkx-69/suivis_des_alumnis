from rest_framework import generics, status, permissions, viewsets, filters
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated, IsAdminUser
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.tokens import RefreshToken


from .models import Etudiant, Alumni, ParcoursAcademique, ParcoursProfessionnel, CustomUser
from .serializers import (
    RegisterEtudiantSerializer, RegisterAlumniSerializer,
    LoginSerializer, EtudiantSerializer, AlumniSerializer,
    UserSerializer, ParcoursAcademiqueSerializer, ParcoursProfessionnelSerializer,
    ChangePasswordSerializer, ChangeEmailSerializer, UpdateUserSerializer, UserPublicSerializer,PublicAlumniProfileSerializer
    )
from .models import POSTES_PAR_SECTEUR
from django.db.models import Q
from random import sample

from rest_framework.generics import RetrieveAPIView
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi


search_param = openapi.Parameter(
    'search', openapi.IN_QUERY,
    description="Recherche par nom, prénom ou username",
    type=openapi.TYPE_STRING
)

class SearchUserView(generics.ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = UserPublicSerializer

    @swagger_auto_schema(
        operation_description="Rechercher des utilisateurs par nom, prénom, username ou email (accessible sans authentification).",
        manual_parameters=[
            openapi.Parameter(
                'q',
                openapi.IN_QUERY,
                description="Terme de recherche (nom, prénom, username ou email)",
                type=openapi.TYPE_STRING,
                required=False
            )
        ],
        responses={200: UserPublicSerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    def get_queryset(self):
        query = self.request.GET.get('q', '')
        return CustomUser.objects.filter(
            Q(username__icontains=query) |
            Q(nom__icontains=query) |
            Q(prenom__icontains=query) |
            Q(email__icontains=query),
            is_active=True
        )
    

class PostesParSecteurAPIView(APIView):
    permission_classes = [AllowAny]

    def get(self, request):
        data = []

        for secteur, postes in POSTES_PAR_SECTEUR:
            data.append({
                "secteur": secteur,
                "postes": [{"code": code, "libelle": label} for code, label in postes]
            })

        return Response(data)


class SuggestionsView(generics.ListAPIView):
    permission_classes = [AllowAny]
    serializer_class = UserPublicSerializer

    @swagger_auto_schema(
        operation_description="Afficher 10 profils d'utilisateurs à découvrir aléatoirement. Accessible même sans connexion.",
        responses={200: UserPublicSerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    def get_queryset(self):
        users = list(CustomUser.objects.filter(is_active=True))
        if self.request.user.is_authenticated:
            users = [u for u in users if u.id != self.request.user.id]
        return sample(users, min(10, len(users)))



# === AUTHENTIFICATION ===
class LoginAPIView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        return Response(serializer.validated_data)

class MeAPIView(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        return Response(UserSerializer(request.user).data)

# === PROFIL ===
class UpdateProfileAPIView(APIView):
    permission_classes = [IsAuthenticated]
    def put(self, request):
        serializer = UpdateUserSerializer(request.user, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(serializer.data)

# === REGISTREMENTS ===
class RegisterEtudiantAPIView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        serializer = RegisterEtudiantSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        etudiant = serializer.save()
        user = etudiant.user  # Accès au CustomUser

        # Générer les tokens
        token_serializer = TokenObtainPairSerializer(data={
            "email": user.email,
            "password": request.data["user"]["password"],
        })
        token_serializer.is_valid(raise_exception=True)
        tokens = token_serializer.validated_data

        return Response({
            "message": "Étudiant inscrit avec succès",
            "access": tokens["access"],
            "refresh": tokens["refresh"],
            "user": UserSerializer(user).data,
        }, status=status.HTTP_201_CREATED)

class RegisterAlumniAPIView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterAlumniSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        # Génère les tokens JWT pour l'utilisateur créé
        refresh = RefreshToken.for_user(user)
        access_token = str(refresh.access_token)
        refresh_token = str(refresh)

        return Response({
            "message": "Alumni inscrit avec succès",
            "access": access_token,
            "refresh": refresh_token
        }, status=status.HTTP_201_CREATED)

# === LISTES POUR ADMIN ===
class ListEtudiantsAPIView(generics.ListAPIView):
    queryset = Etudiant.objects.all()
    serializer_class = EtudiantSerializer
    permission_classes = [IsAuthenticated]

class ListAlumnisAPIView(generics.ListAPIView):
    queryset = Alumni.objects.all()
    serializer_class = AlumniSerializer
    permission_classes = [IsAuthenticated]

# === PERMISSION PERSONNALISÉE ===
class IsOwnerAlumni(permissions.BasePermission):
    def has_object_permission(self, request, view, obj):
        return obj.alumni.user == request.user

# === PARCOURS ===
class ParcoursAcademiqueViewSet(viewsets.ModelViewSet):
    serializer_class = ParcoursAcademiqueSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwnerAlumni]

    def get_queryset(self):
        return ParcoursAcademique.objects.filter(alumni__user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(alumni=self.request.user.alumni)


class ParcoursProfessionnelViewSet(viewsets.ModelViewSet):
    serializer_class = ParcoursProfessionnelSerializer
    permission_classes = [permissions.IsAuthenticated, IsOwnerAlumni]

    def get_queryset(self):
        return ParcoursProfessionnel.objects.filter(alumni__user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(alumni=self.request.user.alumni)


# === MISE À JOUR EMAIL / MOT DE PASSE ===
class ChangePasswordAPIView(APIView):
    permission_classes = [IsAuthenticated]
    def put(self, request):
        serializer = ChangePasswordSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        if not request.user.check_password(serializer.validated_data['old_password']):
            return Response({"error": "Ancien mot de passe incorrect."}, status=400)
        request.user.set_password(serializer.validated_data['new_password'])
        request.user.save()
        return Response({"message": "Mot de passe modifié avec succès."})

class ChangeEmailAPIView(APIView):
    permission_classes = [IsAuthenticated]
    def put(self, request):
        serializer = ChangeEmailSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        request.user.email = serializer.validated_data['email']
        request.user.save()
        return Response({"message": "Email mis à jour avec succès."})

class PublicUserRetrieveAPIView(RetrieveAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserPublicSerializer
    permission_classes = [AllowAny]
    lookup_field = 'username'

    @swagger_auto_schema(
        operation_summary="Afficher le profil public d’un utilisateur",
        operation_description="Permet de consulter le profil public d’un utilisateur à partir de son username, sans authentification."
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
    
class PublicAlumniProfileAPIView(RetrieveAPIView):
    queryset = Alumni.objects.all()
    serializer_class = PublicAlumniProfileSerializer
    permission_classes = [AllowAny]
    lookup_field = 'id' 

    @swagger_auto_schema(
        operation_summary="Profil public complet d’un alumni",
        operation_description="Récupère le profil public d’un alumni à partir de son nom d'utilisateur, incluant les parcours académiques et professionnels."
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)
# === PARCOURS PUBLIQUES PAR ALUMNI ID ===

class PublicParcoursAcademiqueView(generics.ListAPIView):
    serializer_class = ParcoursAcademiqueSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        alumni_id = self.kwargs['alumni_id']
        return ParcoursAcademique.objects.filter(alumni_id=alumni_id)


class PublicParcoursProfessionnelView(generics.ListAPIView):
    serializer_class = ParcoursProfessionnelSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        alumni_id = self.kwargs['alumni_id']
        return ParcoursProfessionnel.objects.filter(alumni_id=alumni_id)
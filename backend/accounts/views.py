from rest_framework import generics, status, permissions, viewsets, filters
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import AllowAny, IsAuthenticated, IsAdminUser
from .models import Etudiant, Alumni, ParcoursAcademique, ParcoursProfessionnel, CustomUser
from .serializers import (
    RegisterEtudiantSerializer, RegisterAlumniSerializer,
    LoginSerializer, EtudiantSerializer, AlumniSerializer,
    UserSerializer, ParcoursAcademiqueSerializer, ParcoursProfessionnelSerializer,
    ChangePasswordSerializer, ChangeEmailSerializer, UpdateUserSerializer
)

class UserSearchView(generics.ListAPIView):
    queryset = CustomUser.objects.all()
    serializer_class = UserSerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['nom', 'prenom', 'username']


class EtudiantSearchView(generics.ListAPIView):
    serializer_class = UserSerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['nom', 'prenom', 'username']

    def get_queryset(self):
        return CustomUser.objects.filter(role='ETUDIANT')


class AlumniSearchView(generics.ListAPIView):
    serializer_class = UserSerializer
    filter_backends = [filters.SearchFilter]
    search_fields = ['nom', 'prenom', 'username']

    def get_queryset(self):
        return CustomUser.objects.filter(role='ALUMNI')
    
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
        serializer.save()
        return Response({"message": "Étudiant inscrit avec succès"}, status=status.HTTP_201_CREATED)

class RegisterAlumniAPIView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        serializer = RegisterAlumniSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({"message": "Alumni inscrit avec succès"}, status=status.HTTP_201_CREATED)

# === LISTES POUR ADMIN ===
class ListEtudiantsAPIView(generics.ListAPIView):
    queryset = Etudiant.objects.all()
    serializer_class = EtudiantSerializer
    permission_classes = [IsAdminUser]

class ListAlumnisAPIView(generics.ListAPIView):
    queryset = Alumni.objects.all()
    serializer_class = AlumniSerializer
    permission_classes = [IsAdminUser]

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

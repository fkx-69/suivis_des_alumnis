from rest_framework import serializers
from filiere.models import Filiere
from .models import CustomUser, Etudiant, Alumni, ParcoursAcademique, ParcoursProfessionnel, Role
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken

# === USER SERIALIZER ===
class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = CustomUser
        fields = ['id', 'email', 'username', 'nom', 'prenom', 'role', 'photo_profil', 'biographie', 'password']
        extra_kwargs = {
            'password': {'write_only': True}
        }
    def get_filiere(self, user):
        try:
            return user.etudiant.filiere.nom
        except:
            return None

# === ÉTUDIANT REGISTRATION SERIALIZER ===
class RegisterEtudiantSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    filiere = serializers.CharField()  # Reçoit un code (ex: "IRT")

    class Meta:
        model = Etudiant
        fields = ['user', 'filiere', 'niveau_etude', 'annee_entree']

    def create(self, validated_data):
        user_data = validated_data.pop('user')
        filiere_code = validated_data.pop('filiere')

        try:
            filiere = Filiere.objects.get(code=filiere_code)
        except Filiere.DoesNotExist:
            raise serializers.ValidationError({'filiere': "Filière invalide"})

        password = user_data.pop('password')
        user_data['role'] = Role.ETUDIANT
        user = CustomUser.objects.create_user(**user_data, password=password)

        etudiant = Etudiant.objects.create(user=user, filiere=filiere, **validated_data)
        return etudiant

# === ALUMNI REGISTRATION SERIALIZER ===
class RegisterAlumniSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    filiere = serializers.CharField()  # Reçoit un code (ex: "IRT")

    class Meta:
        model = Alumni
        fields = ['user', 'filiere', 'secteur_activite', 'situation_pro', 'poste_actuel', 'nom_entreprise']

    def create(self, validated_data):
        user_data = validated_data.pop('user')
        filiere_code = validated_data.pop('filiere')

        try:
            filiere = Filiere.objects.get(code=filiere_code)
        except Filiere.DoesNotExist:
            raise serializers.ValidationError({'filiere': "Filière invalide"})

        password = user_data.pop('password')
        user_data['role'] = Role.ALUMNI
        user = CustomUser.objects.create_user(**user_data, password=password)

        alumni = Alumni.objects.create(user=user, filiere=filiere, **validated_data)
        return alumni
  
# === LOGIN SERIALIZER ===
class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        user = authenticate(email=data['email'], password=data['password'])
        if not user:
            raise serializers.ValidationError("Email ou mot de passe incorrect")
        if not user.is_active:
            raise serializers.ValidationError("Ce compte est désactivé")
        if user.is_banned:
            raise serializers.ValidationError("Ce compte a été banni par un administrateur.")

        refresh = RefreshToken.for_user(user)
        return {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'user': UserSerializer(user).data
        }

# === ÉTUDIANT READ SERIALIZER ===
class EtudiantSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    filiere = serializers.CharField()

    class Meta:
        model = Etudiant
        fields = ['user', 'filiere', 'niveau_etude', 'annee_entree']

    def create(self, validated_data):
        user_data = validated_data.pop('user')
        filiere_code = validated_data.pop('filiere')
        filiere = Filiere.objects.get(code=filiere_code)

        user = CustomUser.objects.create_user(**user_data)
        user.role = Role.ETUDIANT
        user.save()

        etudiant = Etudiant.objects.create(user=user, filiere=filiere, **validated_data)
        return etudiant

# === AUTRES SERIALIZERS ===
class AlumniSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    filiere = serializers.CharField()

    class Meta:
        model = Alumni
        fields = ['user', 'filiere' , 'secteur_activite', 'situation_pro', 'poste_actuel', 'nom_entreprise']

    def create(self, validated_data):
        user_data = validated_data.pop('user')
        filiere_code = validated_data.pop('filiere')
        filiere = Filiere.objects.get(code=filiere_code)

        user = CustomUser.objects.create_user(**user_data)
        user.role = Role.ALUMNI
        user.save()

        alumni = Alumni.objects.create(user=user, filiere=filiere, **validated_data)
        return alumni


class ParcoursAcademiqueSerializer(serializers.ModelSerializer):
    class Meta:
        model = ParcoursAcademique
        fields = '__all__'
        read_only_fields = ['alumni']

class ParcoursProfessionnelSerializer(serializers.ModelSerializer):
    class Meta:
        model = ParcoursProfessionnel
        fields = '__all__'
        read_only_fields = ['alumni']

class ChangePasswordSerializer(serializers.Serializer):
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True)

class ChangeEmailSerializer(serializers.Serializer):
    email = serializers.EmailField(required=True)

class UpdateUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = CustomUser
        fields = ['username', 'nom', 'prenom', 'photo_profil', 'biographie']

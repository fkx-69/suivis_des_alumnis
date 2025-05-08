from rest_framework import serializers
from .models import CustomUser, Etudiant, Alumni, ParcoursAcademique, ParcoursProfessionnel
from django.contrib.auth import authenticate
from rest_framework_simplejwt.tokens import RefreshToken

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = CustomUser
        fields = ['id', 'email', 'username', 'nom', 'prenom', 'role', 'photo_profil','biographie', 'password']
        extra_kwargs = {
            'password': {'write_only': True}
        }
class RegisterEtudiantSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Etudiant
        fields = ['user', 'filiere', 'niveau_etude', 'annee_entree']

    def create(self, validated_data):
        user_data = validated_data.pop('user')
        password = user_data.pop('password')
        user = CustomUser.objects.create_user(**user_data, password=password, role='etudiant')
        etudiant = Etudiant.objects.create(user=user, **validated_data)
        return etudiant

class RegisterAlumniSerializer(serializers.ModelSerializer):
    user = UserSerializer()

    class Meta:
        model = Alumni
        fields = ['user', 'date_fin_cycle','mention', 'secteur_activite', 'situation_pro', 'poste_actuel', 'nom_entreprise']

    def create(self, validated_data):
        user_data = validated_data.pop('user')
        password = user_data.pop('password')
        user = CustomUser.objects.create_user(**user_data, password=password, role='alumni')
        alumni = Alumni.objects.create(user=user, **validated_data)
        return alumni

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        user = authenticate(email=data['email'], password=data['password'])
        if not user:
            raise serializers.ValidationError("Email ou mot de passe incorrect")
        if not user.is_active:
            raise serializers.ValidationError("Ce compte est désactivé")
        refresh = RefreshToken.for_user(user)
        return {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
            'user': UserSerializer(user).data
        }

class EtudiantSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    class Meta:
        model = Etudiant
        fields = '__all__'

class AlumniSerializer(serializers.ModelSerializer):
    user = UserSerializer()
    class Meta:
        model = Alumni
        fields = '__all__'

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
        fields = ['username', 'nom', 'prenom', 'photo_profil','biographie']

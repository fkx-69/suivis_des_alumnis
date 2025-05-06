from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager

class CustomUserManager(BaseUserManager):
    def create_user(self, email, nom, prenom, username, password=None, **extra_fields):
        if not email:
            raise ValueError("L'email est requis")
        email = self.normalize_email(email)
        user = self.model(email=email, nom=nom, prenom=prenom, username=username, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, nom, prenom, username, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        return self.create_user(email, nom, prenom, username, password, **extra_fields)

class CustomUser(AbstractBaseUser, PermissionsMixin):
    ROLES = (
        ('admin', 'Admin'),
        ('etudiant', 'Étudiant'),
        ('alumni', 'Alumni'),
    )
    email = models.EmailField(max_length=45, unique=True)  
    username = models.CharField(max_length=45, unique=True) 
    nom = models.CharField(max_length=50)
    prenom = models.CharField(max_length=50)
    role = models.CharField(max_length=10, choices=ROLES)
    photo_profil = models.ImageField(upload_to='photos/', null=True, blank=True)

    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = CustomUserManager()
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['nom', 'prenom', 'username']

    def __str__(self):
        return f"{self.prenom} {self.nom} ({self.username}) - {self.role}"

class Etudiant(models.Model):
    FILIERES = (
        ('IRT', 'Informatique, Réseaux et Télécoms'),
        ('SGE', 'Science de Gestion'),
        ('GL', 'Génie Logiciel'),
        ('DRD', 'Droit Relation Internationale Diplomatie'),
    )
    NIVEAUX_ETUDE = (
        ('L1', 'Licence 1'),
        ('L2', 'Licence 2'),
        ('L3', 'Licence 3'),
        ('M1', 'Master 1'),
        ('M2', 'Master 2'),
    )
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    filiere = models.CharField(max_length=8, choices=FILIERES)
    niveau_etude = models.CharField(max_length=8, choices=NIVEAUX_ETUDE)
    annee_entree = models.PositiveIntegerField(choices=[(y, str(y)) for y in range(2016, 2025)])

    def __str__(self):
        return f"Étudiant: {self.user.username}"

class Alumni(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    date_fin_cycle = models.DateField()
    secteur_activite = models.CharField(max_length=45, null=True, blank=True)
    situation_pro = models.CharField(
        max_length=15,
        choices=[
            ('emploi', 'En emploi'),
            ('stage', 'En stage'),
            ('chomage', 'En recherche d\'emploi'),
            ('formation', 'En formation'),
            ('autre', 'Autre')
        ]
    )
    poste_actuel = models.CharField(max_length=45, null=True, blank=True)
    nom_entreprise = models.CharField(max_length=45, null=True, blank=True)

    def __str__(self):
        return f"Alumni: {self.user.username}"

class ParcoursAcademique(models.Model):
    alumni = models.ForeignKey(Alumni, on_delete=models.CASCADE, related_name='parcours_academiques')
    diplome = models.CharField(max_length=45)
    institution = models.CharField(max_length=45)
    annee_obtention = models.PositiveIntegerField()

    def __str__(self):
        return f"{self.diplome} - {self.institution}"

class ParcoursProfessionnel(models.Model):
    alumni = models.ForeignKey(Alumni, on_delete=models.CASCADE, related_name='parcours_professionnels')
    poste = models.CharField(max_length=45)
    entreprise = models.CharField(max_length=45)
    date_debut = models.DateField()
    date_fin = models.DateField(null=True, blank=True)

    def __str__(self):
        return f"{self.poste} - {self.entreprise}"
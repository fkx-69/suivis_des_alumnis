from django.db import models
from filiere.models import Filiere
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
class Role(models.TextChoices): 
        ETUDIANT= 'ETUDIANT','Etudiant'
        ALUMNI = 'ALUMNI','Alumni'
        ADMIN = 'ADMIN','Admin'
class CustomUser(AbstractBaseUser, PermissionsMixin):
   
    email = models.EmailField(max_length=45, unique=True)  
    username = models.CharField(max_length=45, unique=True) 
    nom = models.CharField(max_length=50)
    prenom = models.CharField(max_length=50)
    role = models.CharField(max_length=10, choices=Role.choices,blank=True, null=True)
    photo_profil = models.ImageField(upload_to='photos/', null=True, blank=True)
    biographie = models.TextField (max_length=45,blank=True,null=True)
    is_banned = models.BooleanField(default=False)


    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = CustomUserManager()
    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['nom', 'prenom', 'username']

    def __str__(self):
        return f"{self.prenom} {self.nom} ({self.username}) - {self.role}"

class Etudiant(models.Model):
    NIVEAUX_ETUDE = (
        ('L1', 'Licence 1'),
        ('L2', 'Licence 2'),
        ('L3', 'Licence 3'),
        ('M1', 'Master 1'),
        ('M2', 'Master 2'),
    )
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    filiere = models.ForeignKey(Filiere, on_delete=models.SET_NULL, null=True)
    niveau_etude = models.CharField(max_length=8, choices=NIVEAUX_ETUDE)
    annee_entree = models.PositiveIntegerField(choices=[(y, str(y)) for y in range(2016, 2026)])

    def __str__(self):
        return f"Étudiant: {self.user.username}"

class Alumni(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    filiere = models.ForeignKey(Filiere, on_delete=models.SET_NULL, null=True)
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
    mention = models.CharField (
        max_length=45, null=True, blank=True,
        choices=[
        ('mention_passable', 'Mention Passable'),
        ('mention_assez_bien', 'Mention Assez Bien'),
        ('mention_bien', 'Mention Bien'),
        ('mention_tres_bien', 'Mention Très Bien'),
    ]
    )

    def __str__(self):
        return f"{self.diplome} - {self.institution}"

class ParcoursProfessionnel(models.Model):
    alumni = models.ForeignKey(Alumni, on_delete=models.CASCADE, related_name='parcours_professionnels')
    poste = models.CharField(max_length=45)
    entreprise = models.CharField(max_length=45)
    date_debut = models.DateField()
    type_contrat = models.CharField(
        max_length=15,
        choices=[
            ('CDI', 'CDI'),
            ('CDD', 'CDD'),
            ('stage', 'Stage'),
            ('freelance', 'Freelance'),
            ('autre', 'Autre')
        ],
        default='autre'
    )
    def __str__(self):
        return f"{self.poste} - {self.entreprise}"
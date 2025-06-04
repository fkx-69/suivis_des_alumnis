from django.db import models
from filiere.models import Filiere
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin, BaseUserManager

POSTES_PAR_SECTEUR = [
    ("Marketing et Ventes", [
        ("chef_produit", "Chef de produit"),
        ("responsable_marketing", "Responsable marketing"),
        ("commercial_terrain", "Commercial terrain"),
        ("category_manager", "Category manager"),
        ("chef_ventes", "Chef des ventes"),
    ]),
    ("Ressources Humaines", [
        ("charge_recrutement", "Chargé de recrutement"),
        ("gestionnaire_paie", "Gestionnaire de paie"),
        ("responsable_formation", "Responsable formation"),
        ("charge_relations_sociales", "Chargé des relations sociales"),
        ("consultant_rh", "Consultant RH"),
    ]),
    ("Comptabilité Finance", [
        ("comptable_general", "Comptable général"),
        ("controleur_gestion", "Contrôleur de gestion"),
        ("auditeur_financier", "Auditeur financier"),
        ("analyste_financier", "Analyste financier"),
        ("tresorier_entreprise", "Trésorier d’entreprise"),
    ]),
    ("Marketing Digital", [
        ("community_manager", "Community manager"),
        ("traffic_manager", "Traffic manager"),
        ("seo_sea_manager", "SEO/SEA manager"),
        ("growth_hacker", "Growth hacker"),
        ("responsable_emailing", "Responsable e-mailing"),
    ]),
    ("Communication", [
        ("charge_communication", "Chargé de communication"),
        ("attache_presse", "Attaché de presse"),
        ("directeur_communication", "Directeur de la communication"),
        ("concepteur_redacteur", "Concepteur-rédacteur"),
        ("event_manager", "Event manager"),
    ]),
    ("Logistique et Transport", [
        ("responsable_logistique", "Responsable logistique"),
        ("planificateur_transport", "Planificateur transport"),
        ("gestionnaire_entrepot", "Gestionnaire d’entrepôt"),
        ("chef_quai", "Chef de quai"),
        ("coordinateur_supply_chain", "Coordinateur supply chain"),
    ]),
    ("Informatique, Réseaux et Télécommunications", [
        ("admin_sys_reseaux", "Administrateur systèmes et réseaux"),
        ("ingenieur_telecoms", "Ingénieur télécoms"),
        ("developpeur_logiciel", "Développeur logiciel"),
        ("ingenieur_cybersecurite", "Ingénieur cybersécurité"),
        ("architecte_cloud", "Architecte cloud"),
    ]),
    ("Relations Internationales & Diplomatie", [
        ("attache_diplomatique", "Attaché diplomatique"),
        ("charge_mission_internationale", "Chargé de mission internationale"),
        ("analyste_geopolitique", "Analyste géopolitique"),
        ("coordinateur_ong", "Coordinateur ONG"),
        ("conseiller_ri", "Conseiller en relations publiques internationales"),
    ]),
    ("Autres", [
        ("autres", "Autres"),
    ]),
]

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
    filiere = models.ForeignKey(Filiere, on_delete=models.SET_NULL, null=True,related_name='etudiants')
    niveau_etude = models.CharField(max_length=8, choices=NIVEAUX_ETUDE)
    annee_entree = models.PositiveIntegerField(choices=[(y, str(y)) for y in range(2016, 2026)])

    def __str__(self):
        return f"Étudiant: {self.user.username}"

class Alumni(models.Model):
    user = models.OneToOneField(CustomUser, on_delete=models.CASCADE)
    filiere = models.ForeignKey(Filiere, on_delete=models.SET_NULL, null=True,related_name='alumnis')
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
    poste_actuel = models.CharField(max_length=45,
        choices=POSTES_PAR_SECTEUR,
        null=True,
        blank=True)                            
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
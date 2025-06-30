from django.db import models
from accounts.models import Alumni

class ReponseEnquete(models.Model):
    alumni = models.OneToOneField(Alumni, on_delete=models.CASCADE, related_name='reponse_enquete')
    a_trouve_emploi = models.BooleanField()
    date_debut_emploi = models.DateField(null=True, blank=True)
    
    DOMAINE_CHOICES = [
        ('informatique', 'Informatique'),
        ('reseaux', 'Réseaux'),
        ('telecoms', 'Télécoms'),
        ('gestion', 'Science de gestion'),
        ('droit', 'Droit'),
        ('autre', 'Autre'),
    ]
    domaine = models.CharField(max_length=50, choices=DOMAINE_CHOICES)
    autre_domaine = models.CharField(max_length=100, blank=True, null=True)
    
    note_insertion = models.IntegerField()
    suggestions = models.TextField(blank=True)

    date_reponse = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Enquête - {self.alumni.user.username}"

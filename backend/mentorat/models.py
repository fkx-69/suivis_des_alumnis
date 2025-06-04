from django.db import models
from accounts.models import CustomUser

class DemandeMentorat(models.Model):
    STATUT_CHOICES = [
        ('en_attente', 'En attente'),
        ('acceptee', 'Acceptée'),
        ('refusee', 'Refusée'),
    ]
    
    etudiant = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='demandes_envoyees')
    mentor = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='demandes_recues')
    statut = models.CharField(max_length=20, choices=STATUT_CHOICES, default='en_attente')
    message = models.TextField(blank=True, null=True)
    motif_refus = models.TextField(blank=True, null=True)
    date_demande = models.DateTimeField(auto_now_add=True)
    date_maj = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = ('etudiant', 'mentor')

        def __str__(self):
            return f"{self.etudiant.username} → {self.mentor.username} ({self.statut})"


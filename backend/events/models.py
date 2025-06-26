from django.db import models
from django.conf import settings

class Evenement(models.Model):
    titre = models.CharField(max_length=50)
    description = models.TextField()
    date_debut = models.DateTimeField()
    date_fin = models.DateTimeField()
    image = models.ImageField(upload_to='evenements/', null=True, blank=True)
    createur = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='evenements_crees')
    valide = models.BooleanField(default=False)
    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.titre
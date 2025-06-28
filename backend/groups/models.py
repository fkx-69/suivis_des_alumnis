from django.db import models
from django.conf import settings

class Groupe(models.Model):
    nom_groupe = models.CharField(max_length=50, unique=True)
    description = models.TextField(blank=True)
    image= models.ImageField(null=True, blank=True,upload_to='groupes/')
    createur = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        related_name='groupes_crees',
        on_delete=models.CASCADE
    )
    membres = models.ManyToManyField(
        settings.AUTH_USER_MODEL,
        related_name='groupes_rejoints',
        blank=True
    )
    date_creation = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.nom_groupe
class Message(models.Model):
    groupe = models.ForeignKey(Groupe, related_name='messages', on_delete=models.CASCADE)
    auteur = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    contenu = models.TextField()
    date_envoi = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f'{self.auteur.username} - {self.groupe.nom_groupe}'
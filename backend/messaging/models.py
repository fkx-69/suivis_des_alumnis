from django.db import models
from accounts.models import CustomUser

class MessagePrive(models.Model):
    expediteur = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='messages_envoyes')
    destinataire = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name='messages_recus')
    contenu = models.TextField()
    date_envoi = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.expediteur.username} → {self.destinataire.username}"

from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Publication(models.Model):
    auteur = models.ForeignKey(User, on_delete=models.CASCADE)
    texte = models.TextField(blank=True, null=True)
    photo = models.ImageField(upload_to='publications/photos/', blank=True, null=True)
    video = models.FileField(upload_to='publications/videos/', blank=True, null=True)
    date_publication = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.auteur.username} - {self.date_publication.date()}"

    def clean(self):
        from django.core.exceptions import ValidationError
        if not (self.texte or self.photo or self.video):
            raise ValidationError("Au moins un contenu (texte, photo ou vidéo) est requis.")
        if sum(bool(x) for x in [self.texte, self.photo, self.video]) > 1:
            raise ValidationError("Une seule forme de contenu est autorisée par publication.")

class Commentaire(models.Model):
    publication = models.ForeignKey(Publication, on_delete=models.CASCADE, related_name='commentaires')
    auteur = models.ForeignKey(User, on_delete=models.CASCADE)
    contenu = models.TextField()
    date_commentaire = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Commentaire de {self.auteur.username}"

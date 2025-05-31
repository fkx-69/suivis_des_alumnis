from django.db import models

class Filiere(models.Model):
    code = models.CharField(max_length=10, unique=True)
    nom_complet = models.CharField(max_length=50)

    def __str__(self):
        return f"{self.code} - {self.nom_complet}"

    @property
    def nombre_etudiants(self):
        return self.etudiants.count()

    @property
    def nombre_alumnis(self):
        return self.alumnis.count()
 

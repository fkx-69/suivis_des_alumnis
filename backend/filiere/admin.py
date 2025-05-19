from django.contrib import admin
from .models import Filiere

@admin.register(Filiere)
class FiliereAdmin(admin.ModelAdmin):
    list_display = ('code', 'nom_complet', 'nombre_etudiants','nombre_alumnis')
    search_fields = ('code', 'nom_complet')
    ordering = ('code',)
    readonly_fields = ('nombre_etudiants','nombre_alumnis')

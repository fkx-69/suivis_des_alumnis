from django.contrib import admin
from .models import Evenement

@admin.register(Evenement)
class EvenementAdmin(admin.ModelAdmin):
    list_display = ['titre', 'date_debut', 'date_fin', 'createur', 'valide']
    list_filter = ['valide', 'date_debut']
    search_fields = ['titre', 'createur__username']
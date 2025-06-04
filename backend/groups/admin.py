from django.contrib import admin
from .models import Groupe, Message

@admin.register(Groupe)
class GroupeAdmin(admin.ModelAdmin):
    list_display = ['nom_groupe', 'createur', 'date_creation']
    search_fields = ['nom_groupe', 'createur__username']
    filter_horizontal = ['membres']

@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ['groupe', 'auteur', 'date_envoi']
    search_fields = ['groupe__nom_groupe', 'auteur__username', 'contenu']


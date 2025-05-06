from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import (
    CustomUser, Etudiant, Alumni,
    ParcoursAcademique, ParcoursProfessionnel
)

# Admin pour CustomUser
class CustomUserAdmin(UserAdmin):
    model = CustomUser
    list_display = ('email', 'username', 'prenom', 'nom', 'role', 'is_staff', 'is_active')
    list_filter = ('role', 'is_staff', 'is_active')
    fieldsets = (
        (None, {'fields': ('email', 'username', 'prenom', 'nom', 'password', 'role', 'photo_profil')}),
        ('Permissions', {'fields': ('is_staff', 'is_active', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login',)}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': ('email', 'username', 'prenom', 'nom', 'password1', 'password2', 'role', 'is_staff', 'is_active')}
        ),
    )
    search_fields = ('email', 'username', 'nom', 'prenom')
    ordering = ('email',)

# Admin pour Etudiant
class EtudiantAdmin(admin.ModelAdmin):
    list_display = ('user', 'filiere', 'niveau_etude', 'annee_entree')
    search_fields = ('user__username', 'filiere', 'niveau_etude')
    list_filter = ('filiere', 'niveau_etude', 'annee_entree')

# Admin pour Alumni
class AlumniAdmin(admin.ModelAdmin):
    list_display = ('user', 'poste_actuel', 'nom_entreprise', 'secteur_activite', 'situation_pro')
    search_fields = ('user__username', 'poste_actuel', 'nom_entreprise')
    list_filter = ('secteur_activite', 'situation_pro')

# Admin pour Parcours Académique
class ParcoursAcademiqueAdmin(admin.ModelAdmin):
    list_display = ('alumni', 'diplome', 'institution', 'annee_obtention')
    search_fields = ('alumni__user__username', 'diplome', 'institution')
    list_filter = ('annee_obtention',)

# Admin pour Parcours Professionnel
class ParcoursProfessionnelAdmin(admin.ModelAdmin):
    list_display = ('alumni', 'poste', 'entreprise', 'date_debut', 'date_fin')
    search_fields = ('alumni__user__username', 'poste', 'entreprise')
    list_filter = ('date_debut', 'date_fin')

# Enregistrement des modèles
admin.site.register(CustomUser, CustomUserAdmin)
admin.site.register(Etudiant, EtudiantAdmin)
admin.site.register(Alumni, AlumniAdmin)
admin.site.register(ParcoursAcademique, ParcoursAcademiqueAdmin)
admin.site.register(ParcoursProfessionnel, ParcoursProfessionnelAdmin)

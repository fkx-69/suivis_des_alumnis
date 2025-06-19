from django.contrib import admin, messages
from django.contrib.auth.admin import UserAdmin
from django import forms
from django.shortcuts import render, redirect
from django.contrib.admin.helpers import ACTION_CHECKBOX_NAME
from messaging.models import MessagePrive


class SendMessageForm(forms.Form):
    """Simple form used to write the content of a private message."""

    _selected_action = forms.CharField(widget=forms.MultipleHiddenInput)
    contenu = forms.CharField(label="Message", widget=forms.Textarea)


def envoyer_message_prive(modeladmin, request, queryset):
    """Admin action to send a private message to selected users."""

    if "apply" in request.POST:
        form = SendMessageForm(request.POST)
        if form.is_valid():
            contenu = form.cleaned_data["contenu"]
            for user in queryset:
                MessagePrive.objects.create(
                    expediteur=request.user,
                    destinataire=user,
                    contenu=contenu,
                )
            modeladmin.message_user(
                request,
                f"Message envoyé à {queryset.count()} utilisateur(s).",
                messages.SUCCESS,
            )
            return redirect(request.get_full_path())
    else:
        form = SendMessageForm(
            initial={"_selected_action": request.POST.getlist(ACTION_CHECKBOX_NAME)}
        )

    return render(
        request,
        "admin/envoyer_message.html",
        {"users": queryset, "form": form, "title": "Envoyer un message"},
    )


envoyer_message_prive.short_description = (
    "Envoyer un message privé aux utilisateurs sélectionnés"
)
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
        (None, {
            'fields': (
                'email', 'username', 'prenom', 'nom', 'password',
                'role', 'photo_profil', 'biographie'  
            )
        }),
        ('Permissions', {
            'fields': ('is_staff', 'is_active', 'is_superuser', 'groups', 'user_permissions')
        }),
        ('Important dates', {'fields': ('last_login',)}),
    )
    add_fieldsets = (
        (None, {
            'classes': ('wide',),
            'fields': (
                'email', 'username', 'prenom', 'nom',
                'password1', 'password2', 'role',
                'is_staff', 'is_active'
            )
        }),
    )
    search_fields = ('email', 'username', 'nom', 'prenom')
    ordering = ('email',)
    actions = [envoyer_message_prive]

# Admin pour Etudiant
class EtudiantAdmin(admin.ModelAdmin):
    list_display = ('user', 'filiere', 'niveau_etude', 'annee_entree')
    search_fields = ('user__username', 'filiere', 'niveau_etude')
    list_filter = ('filiere', 'niveau_etude', 'annee_entree')

# Admin pour Alumni
class AlumniAdmin(admin.ModelAdmin):
    list_display = ('user','filiere', 'poste_actuel', 'nom_entreprise', 'secteur_activite', 'situation_pro')
    search_fields = ('user__username', 'poste_actuel', 'nom_entreprise')
    list_filter = ('secteur_activite', 'situation_pro')

# Admin pour Parcours Académique
class ParcoursAcademiqueAdmin(admin.ModelAdmin):
    list_display = ('alumni', 'diplome', 'institution', 'annee_obtention','mention')
    search_fields = ('alumni__user__username', 'diplome', 'institution')
    list_filter = ('annee_obtention',)

# Admin pour Parcours Professionnel
class ParcoursProfessionnelAdmin(admin.ModelAdmin):
    list_display = ('alumni', 'poste', 'entreprise', 'date_debut','type_contrat')
    search_fields = ('alumni__user__username', 'poste', 'entreprise')
    list_filter = ('poste', 'entreprise', 'date_debut', 'type_contrat')

# Enregistrement des modèles
admin.site.register(CustomUser, CustomUserAdmin)
admin.site.register(Etudiant, EtudiantAdmin)
admin.site.register(Alumni, AlumniAdmin)
admin.site.register(ParcoursAcademique, ParcoursAcademiqueAdmin)
admin.site.register(ParcoursProfessionnel, ParcoursProfessionnelAdmin)

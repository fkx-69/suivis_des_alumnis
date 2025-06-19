from django.contrib import admin
from .models import MessagePrive


@admin.register(MessagePrive)
class MessagePriveAdmin(admin.ModelAdmin):
    """Admin for sending private messages."""

    list_display = ["expediteur", "destinataire", "date_envoi"]
    search_fields = ["expediteur__username", "destinataire__username", "contenu"]
    readonly_fields = ["expediteur", "date_envoi"]
    fields = ["destinataire", "contenu"]

    def save_model(self, request, obj, form, change):
        if not change:
            obj.expediteur = request.user
        super().save_model(request, obj, form, change)

from django.contrib import admin
from django.contrib import messages
from .models import Report
from accounts.models import CustomUser

@admin.register(Report)
class ReportAdmin(admin.ModelAdmin):
    list_display = ('reported_by', 'reported_user', 'reason', 'created_at')
    list_filter = ('created_at',)
    search_fields = ('reported_by__username', 'reported_user__username', 'reason')

    actions = ['ban_reported_users', 'delete_reported_users']

    def ban_reported_users(self, request, queryset):
        count = 0
        for report in queryset:
            user = report.reported_user
            if user is not None and not getattr(user, 'is_banned', False):
                user.is_banned = True
                user.save()
                count += 1
        self.message_user(request, f"{count} utilisateur(s) banni(s) avec succès.", messages.SUCCESS)
    ban_reported_users.short_description = "Bannir les utilisateurs signalés sélectionnés"

    def delete_reported_users(self, request, queryset):
        count = 0
        for report in queryset:
            user = report.reported_user
            if user is not None:
                user.delete()
                count += 1
        self.message_user(request, f"{count} utilisateur(s) supprimé(s) avec succès.", messages.SUCCESS)
    delete_reported_users.short_description = "Supprimer les utilisateurs signalés sélectionnés"

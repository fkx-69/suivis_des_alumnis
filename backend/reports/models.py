from django.db import models
from django.conf import settings

class Report(models.Model):
    reported_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        related_name='reports_made', 
        on_delete=models.CASCADE
    )
    reported_user = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        related_name='reports_received', 
        on_delete=models.CASCADE
    )
    reason = models.TextField(
        max_length=50,
        choices=[
            ('comportement_inapproprié', 'Comportement inapproprié'),
            ('contenu_inapproprié', 'Contenu inapproprié'),
            ('autre', 'Autre')
        ],
        default='autre'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ('reported_by', 'reported_user')

    def __str__(self):
        return f"{self.reported_by.username} → {self.reported_user.username}"

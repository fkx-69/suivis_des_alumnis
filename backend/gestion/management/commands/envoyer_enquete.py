from django.core.management.base import BaseCommand
from gestion.utils.enquete import envoyer_email_enquete

class Command(BaseCommand):
    help = "Envoie une enquête par mail à tous les anciens étudiants"

    def handle(self, *args, **kwargs):
        envoyer_email_enquete()
        self.stdout.write(self.style.SUCCESS(" Enquête envoyée à tous les alumnis."))

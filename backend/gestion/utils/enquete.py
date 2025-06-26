from django.core.mail import send_mail
from django.conf import settings
from accounts.models import Alumni

def envoyer_email_enquete():
    google_form_url = "https://forms.gle/uHrXpQNbzsqtPN9d8"

    alumnis = Alumni.objects.filter(user__email__isnull=False)

    for alumni in alumnis:
        destinataire = alumni.user.email
        sujet = "Enquête sur votre situation professionnelle (IPTMA)"
        message = (
            f"Bonjour {alumni.user.prenom},\n\n"
            "Dans le cadre du suivi de l'insertion professionnelle des anciens étudiants de l'IPTMA, "
            "nous vous invitons à remplir un court formulaire.\n\n"
            f" Lien du questionnaire : {google_form_url}\n\n"
            "Merci pour votre participation !"
        )

        send_mail(
            sujet,
            message,
            settings.EMAIL_HOST_USER,
            [destinataire],
            fail_silently=False,
        )

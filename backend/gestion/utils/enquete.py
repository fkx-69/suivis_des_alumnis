from django.core.mail import send_mail
from django.conf import settings
from accounts.models import Alumni

def envoyer_questionnaire():
    lien_formulaire = "https://tonapp.com/enquete-form"  # Ce lien doit pointer vers la page du formulaire Flutter ou React que les alumnis doivent remplir

    alumnis = Alumni.objects.filter(user__email__isnull=False)

    for alumni in alumnis:
        destinataire = alumni.user.email
        sujet = "Questionnaire d'insertion professionnelle (IPTMA)"
        message = (
            f"Bonjour {alumni.user.prenom},\n\n"
            "Merci de bien vouloir remplir ce questionnaire sur votre situation professionnelle.\n\n"
            f"Cliquez ici : {lien_formulaire}\n\n"
            "Merci pour votre participation !"
        )

        send_mail(
            sujet,
            message,
            settings.EMAIL_HOST_USER,
            [destinataire],
            fail_silently=False,
        )

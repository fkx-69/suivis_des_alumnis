from rest_framework.views import APIView
from rest_framework.permissions import IsAdminUser
from rest_framework.response import Response
from rest_framework import status
from gestion.utils.enquete import envoyer_email_enquete
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

class LancerEnqueteView(APIView):
    permission_classes = [IsAdminUser]

    @swagger_auto_schema(
        operation_description="Déclenche l'envoi d'une enquête Google Form aux alumnis par email.",
        responses={200: "Emails envoyés avec succès."}
    )
    def post(self, request):
        envoyer_email_enquete()
        return Response({"message": "Emails envoyés avec succès."}, status=status.HTTP_200_OK)

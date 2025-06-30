from rest_framework import generics, permissions
from .models import ReponseEnquete
from .serializers import ReponseEnqueteSerializer

from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from .utils.enquete import envoyer_questionnaire

class LancerEnvoiEnqueteAPIView(APIView):
    permission_classes = [IsAdminUser]

    def post(self, request):
        envoyer_questionnaire()
        return Response({"message": "Enquêtes envoyées avec succès."})

@swagger_auto_schema(
    operation_summary="Soumettre une réponse au questionnaire",
    operation_description="Endpoint sécurisé pour que les alumnis répondent au questionnaire d’insertion.",
    responses={201: "Réponse enregistrée"}
)

class SoumettreEnqueteAPIView(generics.CreateAPIView):
    serializer_class = ReponseEnqueteSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        alumni = self.request.user.alumni
        serializer.save(alumni=alumni)

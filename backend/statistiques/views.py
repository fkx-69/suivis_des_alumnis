from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from accounts.models import Alumni
from filiere.models import Filiere
from .serializers import SituationProStatsSerializer, DomaineStatsSerializer
from collections import Counter
from rest_framework import status

from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi


class SituationProStatsView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Retourne des statistiques sur la situation professionnelle des alumnis.",
        responses={200: SituationProStatsSerializer(many=True)}
    )
    def get(self, request):
        situations = Alumni.objects.values_list('situation_pro', flat=True)
        counts = Counter(situations)
        data = [{'situation': k, 'count': v} for k, v in counts.items()]
        serializer = SituationProStatsSerializer(data, many=True)
        return Response(serializer.data)


class DomaineStatsParFiliereView(APIView):
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Retourne les statistiques des domaines d'emploi des alumnis d'une filière donnée.",
        manual_parameters=[
            openapi.Parameter(
                'filiere_id',
                openapi.IN_PATH,
                description="ID de la filière",
                type=openapi.TYPE_INTEGER,
                required=True
            )
        ],
        responses={
            200: DomaineStatsSerializer(many=True),
            404: "Filière introuvable"
        }
    )
    def get(self, request, filiere_id):
        try:
            filiere = Filiere.objects.get(id=filiere_id)
        except Filiere.DoesNotExist:
            return Response({"error": "Filière introuvable."}, status=status.HTTP_404_NOT_FOUND)

        alumnis = filiere.alumnis.all()
        domaines = [alumni.poste_actuel for alumni in alumnis if alumni.poste_actuel]
        counts = Counter(domaines)
        data = [{'domaine': k, 'count': v} for k, v in counts.items()]
        serializer = DomaineStatsSerializer(data, many=True)
        return Response(serializer.data)

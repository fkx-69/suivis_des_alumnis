from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from accounts.models import Alumni
from filiere.models import Filiere
from .serializers import SituationProStatsSerializer, DomaineStatsSerializer
from collections import Counter
from rest_framework import status

class SituationProStatsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        situations = Alumni.objects.values_list('situation_pro', flat=True)
        counts = Counter(situations)
        data = [{'situation': k, 'count': v} for k, v in counts.items()]
        serializer = SituationProStatsSerializer(data, many=True)
        return Response(serializer.data)

class DomaineStatsParFiliereView(APIView):
    permission_classes = [IsAuthenticated]

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

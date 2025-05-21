from rest_framework import generics, permissions, status
from rest_framework.response import Response
from .models import Evenement
from .serializers import EvenementSerializer
from .permissions import IsAdmin, IsEtudiant, IsAlumni
from rest_framework.views import APIView
from django.utils.dateparse import parse_datetime

class CreateEvenementView(generics.CreateAPIView):
    queryset = Evenement.objects.all()
    serializer_class = EvenementSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin | IsEtudiant]

    def perform_create(self, serializer):
        is_admin = self.request.user.is_staff
        serializer.save(createur=self.request.user, valide=is_admin)

class ModifierEvenementView(generics.UpdateAPIView):
    queryset = Evenement.objects.all()
    serializer_class = EvenementSerializer
    permission_classes = [permissions.IsAuthenticated]

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance.createur != request.user:
            return Response({'detail': "Vous n'\u00eates pas le cr\u00e9ateur de cet \u00e9v\u00e9nement."}, status=403)

        # Autoriser modification si admin ou si pas encore validé
        if not request.user.is_staff and instance.valide:
            return Response({'detail': "Vous ne pouvez plus modifier cet \u00e9v\u00e9nement car il a déjà été validé."}, status=403)

        response = super().update(request, *args, **kwargs)
        return Response({"message": f"Cet \u00e9v\u00e9nement '{instance.titre}' a été mis à jour."})

class ValiderEvenementView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsAdmin]

    def post(self, request, pk):
        try:
            evenement = Evenement.objects.get(pk=pk)
            evenement.valide = True
            evenement.save()
            return Response({'message': f"L'\u00e9v\u00e9nement '{evenement.titre}' a été validé."})
        except Evenement.DoesNotExist:
            return Response({'error': 'Evenement non trouvé.'}, status=404)

class ListeEvenementsVisiblesView(generics.ListAPIView):
    serializer_class = EvenementSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Evenement.objects.filter(valide=True).order_by('-date_debut')


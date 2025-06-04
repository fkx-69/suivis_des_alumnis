from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Evenement
from .serializers import EvenementSerializer
from .permissions import IsAdmin, IsEtudiant
from django.utils.dateparse import parse_datetime
from accounts.models import CustomUser
from notifications.utils import envoyer_notification

class CreateEvenementView(generics.CreateAPIView):
    queryset = Evenement.objects.all()
    serializer_class = EvenementSerializer
    permission_classes = [permissions.IsAuthenticated, IsAdmin | IsEtudiant]

    def perform_create(self, serializer):
        is_admin = self.request.user.is_staff
        evenement = serializer.save(createur=self.request.user, valide=is_admin)

        # Envoyer une notification à tous les utilisateurs si créé par un admin (donc validé directement)
        if is_admin:
            utilisateurs = CustomUser.objects.exclude(id=self.request.user.id)
            for utilisateur in utilisateurs:
                envoyer_notification(
                    utilisateur,
                    f"Un nouvel événement '{evenement.titre}' a été publié."
                )

class ModifierEvenementView(generics.UpdateAPIView):
    queryset = Evenement.objects.all()
    serializer_class = EvenementSerializer
    permission_classes = [permissions.IsAuthenticated]

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance.createur != request.user:
            return Response({'detail': "Vous n'êtes pas le créateur de cet événement."}, status=403)

        # Autoriser modification si admin ou si pas encore validé
        if not request.user.is_staff and instance.valide:
            return Response({'detail': "Vous ne pouvez plus modifier cet événement car il a déjà été validé."}, status=403)

        response = super().update(request, *args, **kwargs)

        # Notifier tous les utilisateurs si l'événement est déjà validé
        if instance.valide:
            utilisateurs = CustomUser.objects.exclude(id=request.user.id)
            for utilisateur in utilisateurs:
                envoyer_notification(
                    utilisateur,
                    f"L'événement '{instance.titre}' a été modifié."
                )

        return Response({"message": f"Cet événement '{instance.titre}' a été mis à jour."})

class ValiderEvenementView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsAdmin]

    def post(self, request, pk):
        try:
            evenement = Evenement.objects.get(pk=pk)
            evenement.valide = True
            evenement.save()

            # Notifier tous les utilisateurs sauf le créateur
            utilisateurs = CustomUser.objects.exclude(id=evenement.createur.id)
            for utilisateur in utilisateurs:
                envoyer_notification(
                    utilisateur,
                    f"Un nouvel événement '{evenement.titre}' a été publié."
                )

            # Notifier le créateur que son événement a été validé
            envoyer_notification(
                evenement.createur,
                f"Votre événement '{evenement.titre}' a été validé par l'administration."
            )

            return Response({'message': f"L'événement '{evenement.titre}' a été validé."})
        except Evenement.DoesNotExist:
            return Response({'error': 'Événement non trouvé.'}, status=404)

class ListeEvenementsVisiblesView(generics.ListAPIView):
    serializer_class = EvenementSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Evenement.objects.filter(valide=True).order_by('-date_debut')
    
class SupprimerEvenementView(generics.DestroyAPIView):
    queryset = Evenement.objects.all()
    serializer_class = EvenementSerializer
    permission_classes = [permissions.IsAuthenticated]

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()

        # Récupérer les infos
        createur = instance.createur
        titre_event = instance.titre
        user = request.user

        # Cas: étudiant => peut supprimer **seulement si non validé et s'il est le créateur**
        if user == createur:
            if instance.valide:
                return Response({'detail': "Vous ne pouvez pas supprimer un événement validé."}, status=403)
            self.perform_destroy(instance)
            return Response({'message': f"Votre événement '{titre_event}' a été supprimé."})
from rest_framework import generics, status, serializers
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import PermissionDenied
from .models import DemandeMentorat
from .serializers import DemandeMentoratSerializer
from .permissions import IsEtudiant, IsAlumni, IsOwnerOrReadOnly
from notifications.utils import envoyer_notification


class EnvoyerDemandeView(generics.CreateAPIView):
    queryset = DemandeMentorat.objects.all()
    serializer_class = DemandeMentoratSerializer
    permission_classes = [IsAuthenticated, IsEtudiant]

    def perform_create(self, serializer):
        mentor_username = self.request.data.get('mentor_username')
        from accounts.models import CustomUser
        try:
            mentor = CustomUser.objects.get(username=mentor_username, role='ALUMNI')
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError("Mentor non trouvé ou invalide.")

        demande = serializer.save(etudiant=self.request.user, mentor=mentor)

        # ✅ Notifier l'alumni
        envoyer_notification(
            destinataire=mentor,
            message=f"{self.request.user.username} vous a envoyé une demande de mentorat."
        )


class MesDemandesView(generics.ListAPIView):
    serializer_class = DemandeMentoratSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'ETUDIANT':
            return DemandeMentorat.objects.filter(etudiant=user)
        elif user.role == 'ALUMNI':
            return DemandeMentorat.objects.filter(mentor=user)
        return DemandeMentorat.objects.none()


class RepondreDemandeView(generics.UpdateAPIView):
    queryset = DemandeMentorat.objects.all()
    serializer_class = DemandeMentoratSerializer
    permission_classes = [IsAuthenticated, IsAlumni, IsOwnerOrReadOnly]

    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        if instance.mentor != request.user:
            return Response({'detail': "Non autorisé."}, status=403)

        statut = request.data.get('statut')
        motif_refus = request.data.get('motif_refus', None)

        if statut not in ['acceptee', 'refusee']:
            return Response({'detail': "Statut invalide."}, status=400)

        instance.statut = statut
        if statut == 'refusee':
            instance.motif_refus = motif_refus
        instance.save()

        # ✅ Notifier l’étudiant de la réponse
        message = (
            f"Votre demande de mentorat a été acceptée par {request.user.username}."
            if statut == 'acceptee'
            else f"Votre demande de mentorat a été refusée par {request.user.username}."
        )
        envoyer_notification(
            destinataire=instance.etudiant,
            message=message
        )

        return Response(self.get_serializer(instance).data)


class SupprimerDemandeView(generics.DestroyAPIView):
    queryset = DemandeMentorat.objects.all()
    serializer_class = DemandeMentoratSerializer
    permission_classes = [IsAuthenticated, IsEtudiant]

    def perform_destroy(self, instance):
        if instance.etudiant != self.request.user:
            raise PermissionDenied("Vous ne pouvez annuler que vos propres demandes.")
        if instance.statut != 'en_attente':
            raise PermissionDenied("Vous ne pouvez annuler qu'une demande en attente.")
        instance.delete()


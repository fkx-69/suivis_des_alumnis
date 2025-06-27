from rest_framework import generics, status, serializers
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import PermissionDenied
from .models import DemandeMentorat
from .serializers import DemandeMentoratSerializer
from .permissions import IsEtudiant, IsAlumni, IsOwnerOrReadOnly
from notifications.utils import envoyer_notification
from accounts.models import CustomUser

from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi


# === Envoyer une demande de mentorat ===
class EnvoyerDemandeView(generics.CreateAPIView):
    queryset = DemandeMentorat.objects.all()
    serializer_class = DemandeMentoratSerializer
    permission_classes = [IsAuthenticated, IsEtudiant]

    @swagger_auto_schema(
        operation_description="Envoyer une demande de mentorat à un alumni.",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=["mentor_username"],
            properties={
                "mentor_username": openapi.Schema(type=openapi.TYPE_STRING, description="Nom d'utilisateur du mentor (alumni)"),
            }
        ),
        responses={201: "Demande envoyée", 400: "Mentor non trouvé"}
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def perform_create(self, serializer):
        mentor_username = self.request.data.get('mentor_username')
        try:
            mentor = CustomUser.objects.get(username=mentor_username, role='ALUMNI')
        except CustomUser.DoesNotExist:
            raise serializers.ValidationError("Mentor non trouvé ou invalide.")

        demande = serializer.save(etudiant=self.request.user, mentor=mentor)

        envoyer_notification(
            destinataire=mentor,
            message=f"{self.request.user.username} vous a envoyé une demande de mentorat."
        )


# === Voir mes demandes de mentorat ===
class MesDemandesView(generics.ListAPIView):
    serializer_class = DemandeMentoratSerializer
    permission_classes = [IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Voir les demandes de mentorat (en tant qu'étudiant ou alumni).",
        responses={200: DemandeMentoratSerializer(many=True)}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    def get_queryset(self):
        user = self.request.user
        if user.role == 'ETUDIANT':
            return DemandeMentorat.objects.filter(etudiant=user)
        elif user.role == 'ALUMNI':
            return DemandeMentorat.objects.filter(mentor=user)
        return DemandeMentorat.objects.none()


# === Répondre à une demande de mentorat ===
class RepondreDemandeView(generics.UpdateAPIView):
    queryset = DemandeMentorat.objects.all()
    serializer_class = DemandeMentoratSerializer
    permission_classes = [IsAuthenticated, IsAlumni, IsOwnerOrReadOnly]


    def put(self, request, *args, **kwargs):
        raise NotImplementedError("Cette méthode n'est pas disponible. Utilisez PATCH.")

    @swagger_auto_schema(
        operation_description="Accepter ou refuser une demande de mentorat.",
        request_body=openapi.Schema(
            type=openapi.TYPE_OBJECT,
            required=["statut"],
            properties={
                "statut": openapi.Schema(
                    type=openapi.TYPE_STRING,
                    enum=["acceptee", "refusee"],
                    description="Statut à appliquer (acceptee ou refusee)"
                ),
                "motif_refus": openapi.Schema(
                    type=openapi.TYPE_STRING,
                    description="Motif du refus (facultatif)"
                ),
            }
        ),
        responses={
            200: DemandeMentoratSerializer,
            400: "Statut invalide",
            403: "Non autorisé"
        }
    )
    def patch(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

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

        message = (
            f"Votre demande de mentorat a été acceptée par {request.user.username}."
            if statut == 'acceptee'
            else f"Votre demande de mentorat a été refusée par {request.user.username}."
        )

        envoyer_notification(destinataire=instance.etudiant, message=message)

        return Response(self.get_serializer(instance).data)

# === Supprimer (annuler) une demande ===
class SupprimerDemandeView(generics.DestroyAPIView):
    queryset = DemandeMentorat.objects.all()
    serializer_class = DemandeMentoratSerializer
    permission_classes = [IsAuthenticated, IsEtudiant]

    @swagger_auto_schema(
        operation_description="Supprimer une demande de mentorat (seulement si en attente).",
        responses={
            204: "Demande supprimée",
            403: "Non autorisé"
        }
    )
    def delete(self, request, *args, **kwargs):
        return super().delete(request, *args, **kwargs)

    def perform_destroy(self, instance):
        if instance.etudiant != self.request.user:
            raise PermissionDenied("Vous ne pouvez annuler que vos propres demandes.")
        if instance.statut != 'en_attente':
            raise PermissionDenied("Vous ne pouvez annuler qu'une demande en attente.")
        instance.delete()

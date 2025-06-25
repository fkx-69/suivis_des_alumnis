from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Evenement
from .serializers import EvenementSerializer
from .permissions import IsAdmin, IsEtudiant
from accounts.models import CustomUser
from notifications.utils import envoyer_notification
from drf_yasg.utils import swagger_auto_schema
from drf_yasg import openapi


class CreateEvenementView(generics.CreateAPIView):
    queryset = Evenement.objects.all()
    serializer_class = EvenementSerializer
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Créer un événement. S'il est créé par un admin, il est automatiquement validé.",
        request_body=EvenementSerializer,
        responses={201: "Événement créé avec succès"}
    )
    def post(self, request, *args, **kwargs):
        return super().post(request, *args, **kwargs)

    def perform_create(self, serializer):
        is_admin = self.request.user.is_staff
        evenement = serializer.save(createur=self.request.user, valide=is_admin)

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

    @swagger_auto_schema(
        operation_description="Modifier un événement (créateur si non validé ou admin uniquement).",
        manual_parameters=[
            openapi.Parameter('pk', openapi.IN_PATH, description="ID de l'événement", type=openapi.TYPE_INTEGER)
        ],
        request_body=EvenementSerializer
    )
    def put(self, request, *args, **kwargs):
        return self.update(request, *args, **kwargs)

    def update(self, request, *args, **kwargs):
        instance = self.get_object()

        if instance.valide:
            if not request.user.is_staff:
                return Response({'detail': "Seul un admin peut modifier un événement validé."}, status=403)
        elif instance.createur != request.user and not request.user.is_staff:
            return Response({'detail': "Vous n'êtes pas autorisé à modifier cet événement."}, status=403)

        response = super().update(request, *args, **kwargs)

        if instance.valide:
            utilisateurs = CustomUser.objects.exclude(id=request.user.id)
            for utilisateur in utilisateurs:
                envoyer_notification(
                    utilisateur,
                    f"L'événement '{instance.titre}' a été modifié."
                )

        return Response({"message": f"L'événement '{instance.titre}' a été mis à jour."})


class SupprimerEvenementView(generics.DestroyAPIView):
    queryset = Evenement.objects.all()
    serializer_class = EvenementSerializer
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Supprimer un événement (créateur si non validé ou admin uniquement).",
        manual_parameters=[
            openapi.Parameter('pk', openapi.IN_PATH, description="ID de l'événement", type=openapi.TYPE_INTEGER)
        ]
    )
    def delete(self, request, *args, **kwargs):
        return self.destroy(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        user = request.user

        if instance.valide:
            if not user.is_staff:
                return Response({'detail': "Seul un admin peut supprimer un événement validé."}, status=403)
        elif instance.createur != user and not user.is_staff:
            return Response({'detail': "Vous n'êtes pas autorisé à supprimer cet événement."}, status=403)

        titre_event = instance.titre
        self.perform_destroy(instance)
        return Response({'message': f"L'événement '{titre_event}' a été supprimé."})


class ValiderEvenementView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsAdmin]

    @swagger_auto_schema(
        operation_description="Valider un événement (admin uniquement).",
        manual_parameters=[
            openapi.Parameter('pk', openapi.IN_PATH, description="ID de l'événement", type=openapi.TYPE_INTEGER)
        ]
    )
    def post(self, request, pk):
        try:
            evenement = Evenement.objects.get(pk=pk)
            evenement.valide = True
            evenement.save()

            utilisateurs = CustomUser.objects.exclude(id=evenement.createur.id)
            for utilisateur in utilisateurs:
                envoyer_notification(utilisateur, f"Un nouvel événement '{evenement.titre}' a été validé.")

            envoyer_notification(evenement.createur, f"Votre événement '{evenement.titre}' a été validé.")
            return Response({'message': f"L'événement '{evenement.titre}' a été validé."})
        except Evenement.DoesNotExist:
            return Response({'error': 'Événement non trouvé.'}, status=404)


class ListeEvenementsVisiblesView(generics.ListAPIView):
    serializer_class = EvenementSerializer
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Lister les événements validés (pour tous les utilisateurs)."
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    def get_queryset(self):
        return Evenement.objects.filter(valide=True).order_by('-date_debut')
    
    def get_serializer_context(self):
        return {'request': self.request}


class MesEvenementsView(generics.ListAPIView):
    serializer_class = EvenementSerializer
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Lister tous les événements créés par l'utilisateur (validés ou non)."
    )
    def get_queryset(self):
        return Evenement.objects.filter(createur=self.request.user).order_by('-date_debut')

class MesEvenementsNonValidésView(generics.ListAPIView):
    serializer_class = EvenementSerializer
    permission_classes = [permissions.IsAuthenticated]

    @swagger_auto_schema(
        operation_description="Récupérer la liste des événements créés par l'utilisateur mais qui ne sont pas encore validés par l'administration.",
        responses={200: openapi.Response("Liste des événements non validés", EvenementSerializer(many=True))}
    )
    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    def get_queryset(self):
        return Evenement.objects.filter(createur=self.request.user, valide=False).order_by('-date_creation')

    def get_serializer_context(self):
        return {'request': self.request}

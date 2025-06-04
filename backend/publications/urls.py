from django.urls import path
from .views import (
    PublicationCreateView,
    PublicationListView,
    PublicationDeleteView,
    CommentaireCreateView,
    CommentaireDeleteView
)

urlpatterns = [
    path('creer/', PublicationCreateView.as_view(), name='creer-publication'),
    path('fil/', PublicationListView.as_view(), name='fil-publications'),
    path('<int:pk>/supprimer/', PublicationDeleteView.as_view(), name='supprimer-publication'),
    path('commenter/', CommentaireCreateView.as_view(), name='commenter-publication'),
    path('commentaire/<int:pk>/supprimer/', CommentaireDeleteView.as_view(), name='supprimer-commentaire'),
]

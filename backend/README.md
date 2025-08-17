# Documentation de l'API Backend

Ce document liste les principaux endpoints exposés par le backend Django. L'URL de base est `/api/`.

## Comptes (`/api/accounts/`)

### POST `/api/accounts/login/`
Authentification d'un utilisateur.
```json
{
  "email": "user@example.com",
  "password": "string"
}
```

### GET `/api/accounts/me/`
Retourne le profil de l'utilisateur connecté.

### PUT `/api/accounts/me/update/`
Mise à jour du profil.
```json
{
  "username": "string",
  "nom": "string",
  "prenom": "string",
  "photo_profil": "<fichier>",
  "biographie": "string"
}
```

### PUT `/api/accounts/change-password/`
```json
{
  "old_password": "string",
  "new_password": "string"
}
```

### PUT `/api/accounts/change-email/`
```json
{
  "email": "new@example.com"
}
```

### POST `/api/accounts/register/etudiant/`
```json
{
  "user": {
    "email": "user@example.com",
    "username": "string",
    "nom": "string",
    "prenom": "string",
    "password": "string"
  },
  "filiere": <id>,
  "niveau_etude": "L1|L2|L3|M1|M2",
  "annee_entree": 2024
}
```

### POST `/api/accounts/register/alumni/`
```json
{
  "user": {
    "email": "user@example.com",
    "username": "string",
    "nom": "string",
    "prenom": "string",
    "password": "string"
  },
  "filiere": <id>,
  "secteur_activite": "string",
  "situation_pro": "emploi|stage|chomage|formation|autre",
  "poste_actuel": "string",
  "nom_entreprise": "string"
}
```

### GET `/api/accounts/etudiants/`
Liste des étudiants.

### GET `/api/accounts/alumnis/`
Liste des alumnis.

### GET `/api/accounts/search/?q=`
Recherche d'utilisateurs par nom, prénom, username ou email.

### GET `/api/accounts/suggestions/`
Liste aléatoire de 10 profils publics.

### GET `/api/accounts/postes-par-secteur/`
Renvoie la liste des secteurs et des postes associés.

### GET `/api/accounts/parcours-academiques/alumni/<id>/`
Liste publique des parcours académiques d'un alumni.

### GET `/api/accounts/parcours-professionnels/alumni/<id>/`
Liste publique des parcours professionnels d'un alumni.

### Ressource `parcours-academiques/`
Endpoints générés par un ViewSet (`parcours-academiques/`):
- `GET /api/accounts/parcours-academiques/` : lister
- `POST /api/accounts/parcours-academiques/` : créer
- `GET /api/accounts/parcours-academiques/<id>/` : récupérer
- `PUT/PATCH /api/accounts/parcours-academiques/<id>/` : modifier
- `DELETE /api/accounts/parcours-academiques/<id>/` : supprimer

Corps de requête pour création/modification :
```json
{
  "diplome": "string",
  "institution": "string",
  "annee_obtention": 2024,
  "mention": "mention_passable|mention_assez_bien|mention_bien|mention_tres_bien"
}
```

### Ressource `parcours-professionnels/`
Endpoints générés par un ViewSet (`parcours-professionnels/`):
- `GET /api/accounts/parcours-professionnels/`
- `POST /api/accounts/parcours-professionnels/`
- `GET /api/accounts/parcours-professionnels/<id>/`
- `PUT/PATCH /api/accounts/parcours-professionnels/<id>/`
- `DELETE /api/accounts/parcours-professionnels/<id>/`

Corps de requête :
```json
{
  "poste": "string",
  "entreprise": "string",
  "date_debut": "YYYY-MM-DD",
  "type_contrat": "CDI|CDD|stage|freelance|autre"
}
```

## Filière (`/api/filiere/`)

### GET `/api/filiere/`
Liste des filières.

### POST `/api/filiere/`
```json
{
  "code": "string",
  "nom_complet": "string"
}
```

### DELETE `/api/filiere/<id>/`
Suppression (admin).

## Groupes (`/api/groups/`)

### POST `/api/groups/creer/`
Créer un groupe.
```json
{
  "nom_groupe": "string",
  "description": "string",
  "image": "<fichier>"
}
```

### GET `/api/groups/listes/`
Liste de tous les groupes.

### GET `/api/groups/mes-groupes/`
Groupes auxquels l'utilisateur appartient.

### POST `/api/groups/<groupe_id>/rejoindre/`
Rejoindre un groupe.

### POST `/api/groups/<groupe_id>/quitter/`
Quitter un groupe.

### GET `/api/groups/<groupe_id>/membres/`
Liste des membres du groupe.

### POST `/api/groups/<groupe_id>/envoyer-message/`
```json
{
  "contenu": "string"
}
```

### GET `/api/groups/<groupe_id>/messages/`
Messages d'un groupe.

## Publications (`/api/publications/`)

### POST `/api/publications/creer/`
```json
{
  "texte": "string",
  "photo": "<fichier>",
  "video": "<fichier>"
}
```

### GET `/api/publications/fil/`
Fil des publications.

### DELETE `/api/publications/<id>/supprimer/`
Suppression d'une publication (auteur uniquement).

### POST `/api/publications/commenter/`
```json
{
  "publication": <id>,
  "contenu": "string"
}
```

### DELETE `/api/publications/commentaire/<id>/supprimer/`
Supprimer un commentaire.

### GET `/api/publications/utilisateur/<username>/`
Publications d'un utilisateur.

## Événements (`/api/events/`)

### POST `/api/events/evenements/creer/`
```json
{
  "titre": "string",
  "description": "string",
  "image": "<fichier>",
  "date_debut": "YYYY-MM-DDTHH:MM",
  "date_fin": "YYYY-MM-DDTHH:MM"
}
```

### PUT `/api/events/evenements/<id>/modifier/`
Même structure que la création.

### DELETE `/api/events/evenements/<id>/supprimer/`
Supprimer un événement.

### POST `/api/events/evenements/<id>/valider/`
Valider un événement (admin).

### GET `/api/events/evenements/`
Lister les événements validés.

### GET `/api/events/evenements/mes/`
Événements créés par l'utilisateur.

### GET `/api/events/mes-evenements-en-attente/`
Événements en attente de validation.

## Mentorat (`/api/mentorat/`)

### POST `/api/mentorat/envoyer/`
```json
{
  "mentor_username": "string",
  "message": "string"
}
```

### GET `/api/mentorat/mes-demandes/`
Liste des demandes de mentorat de l'utilisateur (étudiant ou mentor).

### PATCH `/api/mentorat/repondre/<id>/`
```json
{
  "statut": "acceptee|refusee",
  "motif_refus": "string" // optionnel
}
```

### DELETE `/api/mentorat/supprimer/<id>/`
Annuler une demande (étudiant).

## Notifications (`/api/notifications/`)

### GET `/api/notifications/`
Liste des notifications de l'utilisateur.

## Messagerie privée (`/api/messaging/`)

### POST `/api/messaging/envoyer/`
```json
{
  "destinataire_username": "string",
  "contenu": "string"
}
```

### GET `/api/messaging/recus/`
Messages reçus.

### GET `/api/messaging/envoyes/`
Messages envoyés.

### GET `/api/messaging/with/<username>/`
Messages échangés avec un utilisateur.

### GET `/api/messaging/conversations/`
Liste des conversations.

## Gestion des enquêtes (`/api/gestion/`)

### POST `/api/gestion/lancer-enquete/`
Déclenche l'envoi du questionnaire (admin).

### POST `/api/gestion/repondre/`
Soumettre la réponse au questionnaire.
```json
{
  "a_trouve_emploi": true,
  "date_debut_emploi": "YYYY-MM-DD",
  "domaine": "informatique|reseaux|telecoms|gestion|droit|autre",
  "autre_domaine": "string",
  "note_insertion": 5,
  "suggestions": "string"
}
```

## Signalements (`/api/reports/`)

### POST `/api/reports/report/`
```json
{
  "reported_user_id": <id>,
  "reason": "string"
}
```

### GET `/api/reports/reports/`
Liste des signalements (admin).

### POST `/api/reports/ban/<user_id>/`
Bannir un utilisateur (admin).

### DELETE `/api/reports/delete/<user_id>/`
Supprimer un utilisateur (admin).

## Statistiques (`/api/statistiques/`)

### GET `/api/statistiques/situation/`
Statistiques sur la situation professionnelle.

### GET `/api/statistiques/domaines/<filiere_id>/`
Répartition des domaines d'emploi pour une filière.


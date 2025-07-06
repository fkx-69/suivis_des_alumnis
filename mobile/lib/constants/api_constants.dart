class ApiConstants {
  //static const String baseUrl = "http://172.20.10.2:8000/api"; // localhost Android/emulator
  static const String baseUrl = "http://localhost:8000/api"; // pour web

  // Auth
  static const String login = '$baseUrl/accounts/login/';
  static const String registerEtudiant = '$baseUrl/accounts/register/etudiant/';
  static const String registerAlumni = '$baseUrl/accounts/register/alumni/';
  static const String userInfo = '$baseUrl/accounts/me/';
  static const String userUpdate = '$baseUrl/accounts/me/update/';
  static const String changePassword = '$baseUrl/accounts/change-password/';
  static const String changeEmail = '$baseUrl/accounts/change-email/';
  static const String verifyPassword = '$baseUrl/accounts/verify-password/';
  static const String getProfile = '$baseUrl/accounts/profile_widgets';
  static const String alumnisList = '$baseUrl/accounts/alumnis/';
  static const String publicAlumniProfileById= '$baseUrl/accounts/alumni/public/{id}/';

  // Profil public
  static const String accountRead = '$baseUrl/accounts/{username}/';

  // Messagerie
  static const String messagingSend = '$baseUrl/messaging/envoyer/';

  // Mentorat
  static const String mentoratSend = '$baseUrl/mentorat/envoyer/';
  static const String mentoratMyRequests = '$baseUrl/mentorat/mes-demandes/';
  static const String mentoratRespond = '$baseUrl/mentorat/repondre/{id}/';
  static const String mentoratDelete = '$baseUrl/mentoring/delete/';

  // Notifications
  static const String notifications = '$baseUrl/notifications/';
  static const String notificationMarkRead = '$baseUrl/notifications/{id}/mark-as-read/';
  static const String notificationDelete = '$baseUrl/notifications/{id}/delete/';

  // Signalement
  static const String reportsReport = '$baseUrl/reports/report/';

  // Parcours
  // 🎓 Parcours Académiques
  static const String parcoursAcademiquesList = "$baseUrl/accounts/parcours-academiques/";
  static const String parcoursAcademiquesCreate = "$baseUrl/accounts/parcours-academiques/";
  static const String parcoursAcademiquesRead = "$baseUrl/accounts/parcours-academiques/{id}/";
  static const String parcoursAcademiquesUpdate = "$baseUrl/accounts/parcours-academiques/{id}/";
  static const String parcoursAcademiquesPartial = "$baseUrl/accounts/parcours-academiques/{id}/";
  static const String parcoursAcademiquesDelete = "$baseUrl/accounts/parcours-academiques/{id}/";

  // 💼 Parcours Professionnels
  static const String parcoursProfessionnelsList = "$baseUrl/accounts/parcours-professionnels/";
  static const String parcoursProfessionnelsCreate = "$baseUrl/accounts/parcours-professionnels/";
  static const String parcoursProfessionnelsRead = "$baseUrl/accounts/parcours-professionnels/{id}/";
  static const String parcoursProfessionnelsUpdate = "$baseUrl/accounts/parcours-professionnels/{id}/";
  static const String parcoursProfessionnelsPartial = "$baseUrl/accounts/parcours-professionnels/{id}/";
  static const String parcoursProfessionnelsDelete = "$baseUrl/accounts/parcours-professionnels/{id}/";

  static const String parcoursAcademiquesAlumni = '$baseUrl/accounts/parcours-academiques/alumni/';
  static const String parcoursProfessionnelsAlumni = '$baseUrl/accounts/parcours-professionnels/alumni/';
  // Filières
  static const String filieres = '$baseUrl/filiere/';

  /// Récupérer le fil
  static const String publicationsFeed = "$baseUrl/publications/fil/";

  /// Créer une nouvelle publication (texte, photo, vidéo)
  static const String publicationsCreate = "$baseUrl/publications/creer/";

  /// Commenter une publication
  static const String publicationsComment = "$baseUrl/publications/commenter/";
  // Pour commenter une publication
  static const String commenterPublication = "$baseUrl/publications/commenter/";

// Pour supprimer un commentaire
  static String publicationsDeleteComment(int id) =>
      '$baseUrl/publications/commentaire/$id/supprimer/';
  

  /// Supprimer une publication (remplace {id} par l’ID)
  static const String publicationsDelete = "$baseUrl/publications/{id}/supprimer/";

  // Événements
  static const String eventsCalendar = "$baseUrl/events/evenements/"; // GET
  static const String eventsCreate = "$baseUrl/events/evenements/creer/"; // ✅ Bonne URL
  static const String eventsValidate = "$baseUrl/events/evenements/{id}/valider/"; // POST
// EVENTS
  static const String eventsAll = "$baseUrl/events/evenements/"; // GET: Tous les événements
  static const String myEvents = "$baseUrl/events/evenements/mes/"; // GET: Mes événements
  static const String eventsUpdate = "$baseUrl/events/evenements/{id}/modifier/"; // PUT ou PATCH
  static const String eventsDelete = "$baseUrl/events/evenements/{id}/supprimer/"; // DELETE


  // Groupes
  static const String groupsList        = '$baseUrl/groups/listes/';
  static const String myGroupsList      = '$baseUrl/groups/mes-groupes/';
  static const String groupsCreate      = '$baseUrl/groups/creer/';
  static const String groupsJoin        = '$baseUrl/groups/{groupe_id}/rejoindre/';
  static const String groupsQuit        = '$baseUrl/groups/{groupe_id}/quitter/';
  static const String groupsMembers     = '$baseUrl/groups/{groupe_id}/membres/';
  static const String groupsMessages    = '$baseUrl/groups/{groupe_id}/messages/';
  static const String groupsSendMessage = '$baseUrl/groups/{groupe_id}/envoyer-message/';

  // 🎯 Messagerie privée
  static const String messagingConversations   = '$baseUrl/messaging/conversations/';
  static const String messagingSendPrivate            = '$baseUrl/messaging/envoyer/';
  static const String messagingSent            = '$baseUrl/messaging/envoyes/';
  static const String messagingReceived        = '$baseUrl/messaging/recus/';
  static const String messagingWithUser        = '$baseUrl/messaging/with/{username}/';

  static const suggestions = '$baseUrl/accounts/suggestions/';
  static const search = '$baseUrl/accounts/search/';
  static const feed = '$baseUrl/publications/fil/';
  static const events = '$baseUrl/events/evenements/';
  static const userPublic = '$baseUrl/accounts'; // Pour voir un profil via /{username}/

  static const String statDomaines = '$baseUrl/statistiques/domaines';
  static const String statSituation = '$baseUrl/statistiques/situation';
}


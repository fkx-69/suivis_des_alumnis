class ApiConstants {
  static const String baseUrl = "http://localhost:8000/api"; // localhost Android/emulator
  // static const String baseUrl = "http://127.0.0.1:8000/api"; // pour web

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

  // Parcours
  // 🎓 Parcours Académiques
  static const String parcoursAcademiquesList        = "$baseUrl/accounts/parcours-academiques/";
  static const String parcoursAcademiquesCreate      = "$baseUrl/accounts/parcours-academiques/";
  static const String parcoursAcademiquesRead        = "$baseUrl/accounts/parcours-academiques/{id}/";
  static const String parcoursAcademiquesUpdate      = "$baseUrl/accounts/parcours-academiques/{id}/";
  static const String parcoursAcademiquesPartial     = "$baseUrl/accounts/parcours-academiques/{id}/";
  static const String parcoursAcademiquesDelete      = "$baseUrl/accounts/parcours-academiques/{id}/";

  // 💼 Parcours Professionnels
  static const String parcoursProfessionnelsList     = "$baseUrl/accounts/parcours-professionnels/";
  static const String parcoursProfessionnelsCreate   = "$baseUrl/accounts/parcours-professionnels/";
  static const String parcoursProfessionnelsRead     = "$baseUrl/accounts/parcours-professionnels/{id}/";
  static const String parcoursProfessionnelsUpdate   = "$baseUrl/accounts/parcours-professionnels/{id}/";
  static const String parcoursProfessionnelsPartial  = "$baseUrl/accounts/parcours-professionnels/{id}/";
  static const String parcoursProfessionnelsDelete   = "$baseUrl/accounts/parcours-professionnels/{id}/";

  // Filières
  static const String filieres = '$baseUrl/filiere/';

  /// Récupérer le fil
  static const String publicationsFeed = "$baseUrl/publications/fil/";

  /// Créer une nouvelle publication (texte, photo, vidéo)
  static const String publicationsCreate = "$baseUrl/publications/creer/";

  /// Commenter une publication
  static const String publicationsComment = "$baseUrl/publications/commenter/";

  /// Supprimer une publication (remplace {id} par l’ID)
  static const String publicationsDelete = "$baseUrl/publications/{id}/supprimer/";

  // Événements
  // Endpoints "events"
  static const String eventsCalendar       = "$baseUrl/events/evenements/";         // GET
  static const String eventsCreate         = "$baseUrl/events/creer/";              // POST
  static const String eventsDelete         = "$baseUrl/events/evenements/{id}/supprimer/"; // DELETE
  static const String eventsUpdate         = "$baseUrl/events/{id}/modifier/";       // PUT
  static const String eventsPartial        = "$baseUrl/events/{id}/modifier/";       // PATCH
  static const String eventsValidate       = "$baseUrl/events/{id}/valider/";        // POST

  // Endpoints « Groupes »
  static const String groupsList = "$baseUrl/groups/mes/";
  static const String groupsBase          = '$baseUrl/groups/';
  static const String groupsCreate        = '${groupsBase}creer/';
  static const String groupsJoin          = '${groupsBase}{groupe_id}/rejoindre/';
  static const String groupsQuit          = '${groupsBase}{groupe_id}/quitter/';
  static const String groupsMembers       = '${groupsBase}{groupe_id}/membres/';
  static const String groupsMessages      = '${groupsBase}{groupe_id}/messages/';
  static const String groupsSendMessage   = '${groupsBase}{groupe_id}/envoyer-message/';
}

class ApiConstants {
  static const String baseUrl = "http://localhost:8000/api"; // localhost Android/emulator
  // static const String baseUrl = "http://127.0.0.1:8000/api"; // pour web

  // Auth
  static const String login = '$baseUrl/accounts/login/';
  static const String registerEtudiant = '$baseUrl/accounts/register/etudiant/';
  static const String registerAlumni = '$baseUrl/accounts/register/alumni/';
  static const String userInfo = '$baseUrl/accounts/me/';
  static const String updateUserInfo = '$baseUrl/accounts/me/update/';
  static const String changePassword = '$baseUrl/accounts/change-password/';
  static const String changeEmail = '$baseUrl/accounts/change-email/';
  static const String verifyPassword = '$baseUrl/accounts/verify-password/';
  static const String getProfile = '$baseUrl/accounts/profile';

  // Parcours
  static const String parcoursAcademiques = '$baseUrl/accounts/parcours-academiques/';
  static const String parcoursProfessionnels = '$baseUrl/accounts/parcours-professionnels/';

  // Filières
  static const String filieres = '$baseUrl/filiere/';

  // Reports
  static const String reportUser = '$baseUrl/reports/report/';
  static const String banUser = '$baseUrl/reports/ban';
  static const String deleteUser = '$baseUrl/reports/delete';

  // Publications
  static const String publications = '$baseUrl/publications/';
  static const String filPublications = '$baseUrl/publications/fil/';

  // Commentaires
  static String commentaires(int pubId) => '$publications$pubId/commentaires/';
  static String commentaireDetail(int pubId, int comId) => '$publications$pubId/commentaires/$comId/';
  static String reponses(int pubId, int comId) => '$publications$pubId/commentaires/$comId/reponses/';
  static String reponseDetail(int pubId, int comId, int repId) => '$publications$pubId/commentaires/$comId/reponses/$repId/';
}

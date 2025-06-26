class UserModel {
  final int id;
  final String email;
  final String username;
  final String nom;
  final String prenom;
  final String? biographie;
  final String role;
  final String? photoProfil;
  final bool isBanned;

  // Informations académiques (pour les étudiants)
  final String? filiere;
  final String? niveauEtude;
  final int? anneeEntree;

  // Informations professionnelles (pour les alumnis)
  final String? secteurActivite;
  final String? situationPro;
  final String? posteActuel;
  final String? nomEntreprise;

  UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.nom,
    required this.prenom,
    this.biographie,
    required this.role,
    this.photoProfil,
    this.isBanned = false,
    this.filiere,
    this.niveauEtude,
    this.anneeEntree,
    this.secteurActivite,
    this.situationPro,
    this.posteActuel,
    this.nomEntreprise,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json;
    return UserModel(
      id           : json['id'] as int,
      email: userData['email'] ?? '',
      username: userData['username'] ?? '',
      nom: userData['nom'] ?? '',
      prenom: userData['prenom'] ?? '',
      biographie: userData['biographie'],
      role: userData['role'] ?? '',
      photoProfil: userData['photo_profil'],
      isBanned: userData['is_banned'] ?? false,
      filiere: json['filiere'],
      niveauEtude: json['niveau_etude'],
      anneeEntree: json['annee_entree'],
      secteurActivite: json['secteur_activite'],
      situationPro: json['situation_pro'],
      posteActuel: json['poste_actuel'],
      nomEntreprise: json['nom_entreprise'],
    );
  }
}
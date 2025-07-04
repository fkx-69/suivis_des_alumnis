class UserModel {
  final int? id;
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
    final bool hasUserWrapper = json.containsKey('user');
    final userData = hasUserWrapper ? json['user'] as Map<String, dynamic> : json;

    return UserModel(
      id: json['id'] as int?, // toujours à la racine, même s'il y a 'user'
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
  UserModel copyWith({
    int? id,
    String? email,
    String? username,
    String? nom,
    String? prenom,
    String? biographie,
    String? role,
    String? photoProfil,
    String? filiere,
    String? niveauEtude,
    int? anneeEntree,
    String? secteurActivite,
    String? situationPro,
    String? posteActuel,
    String? nomEntreprise,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      biographie: biographie ?? this.biographie,
      role: role ?? this.role,
      photoProfil: photoProfil ?? this.photoProfil,
      filiere: filiere ?? this.filiere,
      niveauEtude: niveauEtude ?? this.niveauEtude,
      anneeEntree: anneeEntree ?? this.anneeEntree,
      secteurActivite: secteurActivite ?? this.secteurActivite,
      situationPro: situationPro ?? this.situationPro,
      posteActuel: posteActuel ?? this.posteActuel,
      nomEntreprise: nomEntreprise ?? this.nomEntreprise,
    );
  }

}

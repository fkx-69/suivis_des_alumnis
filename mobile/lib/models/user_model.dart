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

  String? get profileImageUrl => photoProfil;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Gère le cas où le JSON est enveloppé sous "user"
    final userData = json.containsKey('user')
        ? json['user'] as Map<String, dynamic>
        : json;


    return UserModel(
      // ID toujours présent ; on lève si absent
      id: userData['id'] is int
          ? userData['id'] as int
          : int.parse(userData['id']?.toString() ?? '0'),
      email: userData['email'] as String? ?? '',
      username: userData['username'] as String? ?? '',
      nom: userData['nom'] as String? ?? '',
      prenom: userData['prenom'] as String? ?? '',
      biographie: userData['biographie'] as String?,
      role: userData['role'] as String? ?? '',
      photoProfil: userData['photo_profil'] as String?,
      isBanned: userData['is_banned'] as bool? ?? false,
      filiere: userData['filiere'] as String?,
      niveauEtude: userData['niveau_etude'] as String?,
      anneeEntree: userData['annee_entree'] is int
          ? userData['annee_entree'] as int
          : int.tryParse(userData['annee_entree']?.toString() ?? ''),
      secteurActivite: userData['secteur_activite'] as String?,
      situationPro: userData['situation_pro'] as String?,
      posteActuel: userData['poste_actuel'] as String?,
      nomEntreprise: userData['nom_entreprise'] as String?,
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
      isBanned: isBanned,
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

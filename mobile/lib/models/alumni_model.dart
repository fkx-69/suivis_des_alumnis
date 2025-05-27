class AlumniModel {
  final String email;
  final String username;
  final String nom;
  final String prenom;
  final String password;
  final int filiere;
  final String situationPro;
  final String? secteurActivite;
  final String? posteActuel;
  final String? nomEntreprise;

  AlumniModel({
    required this.email,
    required this.username,
    required this.nom,
    required this.prenom,
    required this.password,
    required this.filiere,
    required this.situationPro,
    this.secteurActivite,
    this.posteActuel,
    this.nomEntreprise,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': {
        'email': email,
        'username': username,
        'nom': nom,
        'prenom': prenom,
        'password': password,
      },
      'filiere': filiere,
      'situation_pro': situationPro,
      'secteur_activite': situationPro == 'chomage' ? null : secteurActivite,
      'poste_actuel': situationPro == 'chomage' ? null : posteActuel,
      'nom_entreprise': situationPro == 'chomage' ? null : nomEntreprise,
    };
  }

  factory AlumniModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return AlumniModel(
      email: user['email'],
      username: user['username'],
      nom: user['nom'],
      prenom: user['prenom'],
      password: '', // on ne récupère pas les mdp
      filiere: json['filiere'],
      situationPro: json['situation_pro'],
      secteurActivite: json['secteur_activite'],
      posteActuel: json['poste_actuel'],
      nomEntreprise: json['nom_entreprise'],
    );
  }

  static const Map<String, String> situationsPro = {
    'emploi': 'En emploi',
    'stage': 'En stage',
    'chomage': 'En recherche d\'emploi',
    'formation': 'En formation',
    'autre': 'Autre'
  };
}

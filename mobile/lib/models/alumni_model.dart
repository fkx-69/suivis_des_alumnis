class AlumniModel {
  final String email;
  final String username;
  final String nom;
  final String prenom;
  final String password;
  final String? biographie;
  final int filiere;
  final String secteurActivite;
  final String situationPro;
  final String? posteActuel;
  final String? nomEntreprise;

  static const Map<String, String> situationsPro = {
    'emploi': 'En emploi',
    'stage': 'En stage',
    'chomage': 'En recherche d\'emploi',
    'formation': 'En formation',
    'autre': 'Autre'
  };

  AlumniModel({
    required this.email,
    required this.username,
    required this.nom,
    required this.prenom,
    required this.password,
    this.biographie,
    required this.filiere,
    required this.secteurActivite,
    required this.situationPro,
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
        'biographie': biographie,
      },
      'filiere': filiere,
      'secteur_activite': secteurActivite,
      'situation_pro': situationPro,
      'poste_actuel': posteActuel,
      'nom_entreprise': nomEntreprise,
    };
  }

  factory AlumniModel.fromJson(Map<String, dynamic> json) {
    return AlumniModel(
      email: json['user']['email'],
      username: json['user']['username'],
      nom: json['user']['nom'],
      prenom: json['user']['prenom'],
      password: json['user']['password'],
      biographie: json['user']['biographie'],
      filiere: json['filiere']['id'],
      secteurActivite: json['secteur_activite'],
      situationPro: json['situation_pro'],
      posteActuel: json['poste_actuel'],
      nomEntreprise: json['nom_entreprise'],
    );
  }
}
class StudentModel {
  final String email;
  final String username;
  final String nom;
  final String prenom;
  final String password;
  final int filiere;              // ✅ ID de la filière (ex: 1, 2, 3)
  final String niveauEtude;       // ex: 'Licence 1'
  final int anneeEntree;          // ex: 2024

  StudentModel({
    required this.email,
    required this.username,
    required this.nom,
    required this.prenom,
    required this.password,
    required this.filiere,         // ID attendu par Django
    required this.niveauEtude,
    required this.anneeEntree,
  });

  Map<String, dynamic> toJson() {
    return {
      'user': {
        'email': email,
        'username': username,
        'nom': nom,
        'prenom': prenom,
        'password': password,
        'role': 'ETUDIANT',
      },
      'filiere': filiere,               // ✅ envoyé en tant qu’ID (entier)
      'niveau_etude': niveauEtude,
      'annee_entree': anneeEntree,
    };
  }
}

const Map<String, String> niveauxEtude = {
  'L1': 'Licence 1',
  'L2': 'Licence 2',
  'L3': 'Licence 3',
  'M1': 'Master 1',
  'M2': 'Master 2',
};


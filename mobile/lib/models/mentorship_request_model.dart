import 'package:memoire/models/user_model.dart';

class MentorshipRequestModel {
  final int id;
  final UserModel etudiant;
  final UserModel mentor;
  final String statut;
  final String? message;
  final String? motifRefus;
  final DateTime dateDemande;
  final DateTime dateMaj;


  MentorshipRequestModel({
    required this.id,
    required this.etudiant,
    required this.mentor,
    required this.statut,
    this.message,
    this.motifRefus,
    required this.dateDemande,
    required this.dateMaj,
  });

  factory MentorshipRequestModel.fromJson(Map<String, dynamic> json) {
    return MentorshipRequestModel(
      id: json['id'] as int? ?? 0,
      etudiant: UserModel(
        id: json['etudiant'] as int? ?? 0,
        username: json['etudiant_username'] as String? ?? 'Utilisateur inconnu',
        nom: json['etudiant_nom'] as String? ?? '',
        prenom: json['etudiant_prenom'] as String? ?? '',
        email: json['etudiant_email'] as String? ?? '',
        role: json['etudiant_role'] as String? ?? '',
        photoProfil: json['etudiant_photo_profil'] as String?,
        niveauEtude: null,
        anneeEntree: null,
        filiere: null,
        secteurActivite: null,
        situationPro: null,
        posteActuel: null,
        nomEntreprise: null,
        isBanned: false,
      ),
      mentor: UserModel(
        id: json['mentor'] as int? ?? 0,
        username: json['mentor_username'] as String? ?? 'Utilisateur inconnu',
        nom: json['mentor_nom'] as String? ?? '',
        prenom: json['mentor_prenom'] as String? ?? '',
        email: json['mentor_email'] as String? ?? '',
        role: json['mentor_role'] as String? ?? '',
        photoProfil: json['mentor_photo_profil'] as String?,
        niveauEtude: null,
        anneeEntree: null,
        filiere: null,
        secteurActivite: null,
        situationPro: null,
        posteActuel: null,
        nomEntreprise: null,
        isBanned: false,
      ),
      statut: json['statut'] as String? ?? 'inconnu',
      message: json['message'] as String?,
      motifRefus: json['motif_refus'] as String?,
      dateDemande: DateTime.tryParse(json['date_demande'] as String? ?? '') ??
          DateTime.now(),
      dateMaj: DateTime.tryParse(json['date_maj'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
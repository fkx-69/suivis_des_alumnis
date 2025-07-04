// lib/models/comment_model.dart
class CommentModel {
  final int id;
  final int publication;
  final String auteurUsername;
  final String contenu;
  final DateTime dateCommentaire;
  final String? auteurPhotoProfil; // ✅ AJOUT

  CommentModel({
    required this.id,
    required this.publication,
    required this.auteurUsername,
    required this.contenu,
    required this.dateCommentaire,
    this.auteurPhotoProfil, // ✅ AJOUT
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      publication: json['publication'],
      auteurUsername: json['auteur_username'],
      contenu: json['contenu'],
      dateCommentaire: DateTime.parse(json['date_commentaire']),
      auteurPhotoProfil: json['auteur_photo_profil'], // ✅ AJOUT
    );
  }
}

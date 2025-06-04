// lib/models/comment_model.dart
class CommentModel {
  final int id;
  final int publication;
  final String auteurUsername;
  final String contenu;
  final DateTime dateCommentaire;

  CommentModel({
    required this.id,
    required this.publication,
    required this.auteurUsername,
    required this.contenu,
    required this.dateCommentaire,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      publication: json['publication'],
      auteurUsername: json['auteur_username'],
      contenu: json['contenu'],
      dateCommentaire: DateTime.parse(json['date_commentaire']),
    );
  }
}

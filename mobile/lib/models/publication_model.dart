import 'comment_model.dart';

class PublicationModel {
  final int id;
  final String auteurUsername;
  final String? texte;
  final String? photo;  // URL
  final String? video;  // URL
  final DateTime datePublication;
  final List<CommentModel> commentaires;

  PublicationModel({
    required this.id,
    required this.auteurUsername,
    this.texte,
    this.photo,
    this.video,
    required this.datePublication,
    required this.commentaires,
  });

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    return PublicationModel(
      id: json['id'],
      auteurUsername: json['auteur_username'],
      texte: json['texte'],
      photo: json['photo'],
      video: json['video'],
      datePublication: DateTime.parse(json['date_publication']),
      commentaires: (json['commentaires'] as List)
          .map((c) => CommentModel.fromJson(c))
          .toList(),
    );
  }
}

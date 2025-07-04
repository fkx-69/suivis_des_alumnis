import 'comment_model.dart';
class PublicationModel {
  final int id;
  final String auteurUsername;
  final String? texte;
  final String? photo;
  final String? video;
  final DateTime datePublication;
  final List<CommentModel> commentaires;
  final int nombresCommentaires; // ✅ ajouter ce champ

  PublicationModel({
    required this.id,
    required this.auteurUsername,
    this.texte,
    this.photo,
    this.video,
    required this.datePublication,
    required this.commentaires,
    required this.nombresCommentaires, // ✅ inclure ici
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
          .map((e) => CommentModel.fromJson(e))
          .toList(),
      nombresCommentaires: json['nombres_commentaires'] ?? 0, // ✅
    );
  }
}

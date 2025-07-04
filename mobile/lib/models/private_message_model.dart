import 'package:memoire/models/user_model.dart';

class PrivateMessageModel {
  final int id;
  final UserModel expediteur;
  final UserModel destinataire;
  final String contenu;
  final DateTime timestamp;
  final bool isRead;

  PrivateMessageModel({
    required this.id,
    required this.expediteur,
    required this.destinataire,
    required this.contenu,
    required this.timestamp,
    required this.isRead,
  });

  factory PrivateMessageModel.fromJson(Map<String, dynamic> json) {
    return PrivateMessageModel(
      id: json['id'],
      expediteur: UserModel.fromJson(json['expediteur']),
      destinataire: UserModel.fromJson(json['destinataire']),
      contenu: json['contenu'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['is_read'] ?? false,
    );
  }
}

import 'package:memoire/models/user_model.dart';

class PrivateMessageModel {
  final int id;
  final UserModel expediteur;
  final int destinataireId; // L'API ne renvoie que l'ID
  final String contenu;
  final DateTime timestamp;

  PrivateMessageModel({
    required this.id,
    required this.expediteur,
    required this.destinataireId,
    required this.contenu,
    required this.timestamp,
  });

  factory PrivateMessageModel.fromJson(Map<String, dynamic> json) {
    return PrivateMessageModel(
      id: json['id'],
      // On reconstruit un UserModel partiel à partir des infos de l'API
      expediteur: UserModel.fromJson({
        'id': json['expediteur'],
        'username': json['expediteur_username'] ?? '',
        // Le reste des infos n'est pas nécessaire pour l'affichage du chat
      }),
      destinataireId: json['destinataire'],
      contenu: json['contenu'] ?? '',
      // On utilise le bon champ de date 'date_envoi'
      timestamp: DateTime.parse(json['date_envoi']),
    );
  }
}

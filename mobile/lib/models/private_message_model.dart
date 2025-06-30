class PrivateMessageModel {
  final int id;
  final String fromUsername;
  final String toUsername;
  final String contenu;
  final DateTime dateEnvoi;

  PrivateMessageModel({
    required this.id,
    required this.fromUsername,
    required this.toUsername,
    required this.contenu,
    required this.dateEnvoi,
  });

  factory PrivateMessageModel.fromJson(Map<String, dynamic> json) {
    return PrivateMessageModel(
      id: json['id'] as int,
      fromUsername: json['from_username'] as String,
      toUsername: json['to_username'] as String,
      contenu: json['contenu'] as String,
      dateEnvoi: DateTime.parse(json['date_envoi'] as String),
    );
  }
}

import 'package:memoire/models/user_model.dart';

class MentorshipRequestModel {
  final int id;
  final UserModel utilisateur;
  final UserModel mentor;
  final String statut;
  final String message;
  final DateTime timestamp;

  MentorshipRequestModel({
    required this.id,
    required this.utilisateur,
    required this.mentor,
    required this.statut,
    required this.message,
    required this.timestamp,
  });

  factory MentorshipRequestModel.fromJson(Map<String, dynamic> json) {
    return MentorshipRequestModel(
      id: json['id'],
      utilisateur: UserModel.fromJson(json['demandeur'] ?? json['utilisateur']),
      mentor: UserModel.fromJson(json['mentor']),
      statut: json['statut'],
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? json['date_demande']),
    );
  }
}

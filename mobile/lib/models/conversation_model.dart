class ConversationModel {
  final int id;
  final String username;
  final String prenom;
  final String nom;
  final String? photoProfil;
  final String lastMessage;
  final DateTime dateLastMessage;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.username,
    required this.prenom,
    required this.nom,
    this.photoProfil,
    required this.lastMessage,
    required this.dateLastMessage,
    required this.unreadCount,
  });

  /// Retourne le nom complet de l'interlocuteur.
  String get fullName => '$prenom $nom';

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      prenom: json['prenom'] ?? 'Utilisateur',
      nom: json['nom'] ?? 'Inconnu',
      photoProfil: json['photo_profil'],
      lastMessage: json['last_message'] ?? '',
      dateLastMessage: json['date_last_message'] != null
          ? DateTime.parse(json['date_last_message'])
          : DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

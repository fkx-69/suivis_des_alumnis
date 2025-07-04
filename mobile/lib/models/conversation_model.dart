class ConversationModel {
  final String withUsername;
  final String lastMessage;
  final DateTime dateLastMessage;
  final int unreadCount;

  ConversationModel({
    required this.withUsername,
    required this.lastMessage,
    required this.dateLastMessage,
    required this.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      withUsername: json['with_username'] ?? 'Utilisateur inconnu',
      lastMessage: json['last_message'] ?? '',
      dateLastMessage: json['date_last_message'] != null
          ? DateTime.parse(json['date_last_message'])
          : DateTime.now(),
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}

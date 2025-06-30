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
      withUsername: json['with_username'] as String,
      lastMessage: json['last_message'] as String,
      dateLastMessage: DateTime.parse(json['date_last_message'] as String),
      unreadCount: json['unread_count'] as int,
    );
  }
}

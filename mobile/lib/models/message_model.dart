class MessageModel {
  final String id;
  final String content;
  final DateTime date;
  final bool isMe;

  MessageModel({
    required this.id,
    required this.content,
    required this.date,
    required this.isMe,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    return MessageModel(
      id: json['id'],
      content: json['content'],
      date: DateTime.parse(json['date']),
      isMe: json['sender_id'] == currentUserId,
    );
  }
}

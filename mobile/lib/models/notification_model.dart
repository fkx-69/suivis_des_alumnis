class NotificationModel {
  final int id;
  final String message;
  final DateTime date;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.message,
    required this.date,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      message: json['message'] ?? 'Notification sans message',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false, // à adapter selon le vrai champ (voir ci-dessous)
    );
  }
}

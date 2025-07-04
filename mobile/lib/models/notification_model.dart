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
    // Le backend renvoie 'verb' pour le message, 'timestamp' pour la date, et 'unread' (bool) pour le statut.
    return NotificationModel(
      id: json['id'],
      message: json['verb'] ?? 'Notification sans message',
      date: DateTime.parse(json['timestamp']),
      isRead: json['unread'] == false, // si unread est true, alors isRead est false
    );
  }
}

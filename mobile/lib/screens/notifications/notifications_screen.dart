import 'package:memoire/models/notification_model.dart';
import 'package:memoire/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<NotificationModel>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = _notificationService.fetchNotifications();
    });
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);
      _loadNotifications(); // Recharger la liste pour refléter le changement
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteNotification(int notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);
      _loadNotifications(); // Recharger la liste
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notification supprimée.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.poppins()),
      ),
      body: FutureBuilder<List<NotificationModel>>(
        future: _notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune notification.'));
          }

          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: Icon(
                  notification.isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                  color: notification.isRead ? Colors.grey : Theme.of(context).primaryColor,
                ),
                title: Text(notification.message, style: GoogleFonts.poppins()),
                subtitle: Text(
                  DateFormat.yMMMd('fr_FR').add_Hms().format(notification.date),
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _deleteNotification(notification.id),
                ),
                onTap: () {
                  if (!notification.isRead) {
                    _markAsRead(notification.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

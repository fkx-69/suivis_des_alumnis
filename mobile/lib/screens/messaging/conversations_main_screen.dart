import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/models/user_model.dart';
import 'package:memoire/screens/messaging/discussions_list_screen.dart';
import 'package:memoire/screens/group/group_list_screen.dart';
import 'package:memoire/screens/messaging/mentorship_management_screen.dart';
import 'package:memoire/models/notification_model.dart';
import 'package:memoire/screens/notifications/notifications_screen.dart';
import 'package:memoire/services/notification_service.dart';

class ConversationsMainScreen extends StatefulWidget {
  const ConversationsMainScreen({super.key});

  @override
  State<ConversationsMainScreen> createState() => _ConversationsMainScreenState();
}

class _ConversationsMainScreenState extends State<ConversationsMainScreen> {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  bool _isAlumni = false;
  bool _isLoading = true;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getUserInfo();
      if (mounted && user != null && user.role.toLowerCase() == 'alumni') {
        _isAlumni = true;
      }
      await _fetchNotifications();
    } catch (e) {
      // Gérer l'erreur
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchNotifications() async {
    try {
      final notifications = await _notificationService.fetchNotifications();
      if (mounted) {
        setState(() {
          _unreadNotifications = notifications.where((n) => !n.isRead).length;
        });
      }
    } catch (e) {
      // Gérer l'erreur
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Tab> tabs = [
      const Tab(text: 'Discussions'),
      const Tab(text: 'Groupes'),
    ];

    final List<Widget> tabViews = [
      const DiscussionsListScreen(),
      const GroupListScreen(),
    ];

    if (_isAlumni) {
      tabs.add(const Tab(text: 'Mentorat'));
      tabViews.add(const MentorshipManagementScreen());
    }

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Messagerie', style: GoogleFonts.poppins()),
          actions: [
            IconButton(
              icon: Badge(
                label: Text('$_unreadNotifications'),
                isLabelVisible: _unreadNotifications > 0,
                child: const Icon(Icons.notifications),
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
                // Recharger les notifications après avoir visité la page
                _fetchNotifications();
              },
            )
          ],
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          bottom: _isLoading
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Center(child: LinearProgressIndicator()),
                )
              : TabBar(
                  indicatorColor: Color(0xFF2196F3),
                  labelColor: Color(0xFF2196F3),
                  unselectedLabelColor: Colors.grey,
                  tabs: tabs,
                ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(children: tabViews),
      ),
    );
  }
}

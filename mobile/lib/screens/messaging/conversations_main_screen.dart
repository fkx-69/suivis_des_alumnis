import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/screens/group/conversation_list_screen.dart';
import 'package:memoire/screens/group/group_list_screen.dart';
import 'package:memoire/screens/messaging/mentorship_management_screen.dart';
import 'package:memoire/screens/notifications/notifications_screen.dart';
import 'package:memoire/services/notification_service.dart';

class ConversationsMainScreen extends StatefulWidget {
  const ConversationsMainScreen({super.key});

  @override
  State<ConversationsMainScreen> createState() => _ConversationsMainScreenState();
}

class _ConversationsMainScreenState extends State<ConversationsMainScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  bool _isAlumni = false;
  bool _isLoading = true;
  int _unreadNotifications = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _loadInitialData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
        _fadeController.forward();
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final List<Tab> tabs = [
      const Tab(text: 'Discussions'),
      const Tab(text: 'Groupes'),
    ];

    final List<Widget> tabViews = [
      const ConversationListScreen(),
      const GroupListScreen(),
    ];

    if (_isAlumni) {
      tabs.add(const Tab(text: 'Mentorat'));
      tabViews.add(const MentorshipManagementScreen());
    }

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            'Messagerie',
            style: textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Badge(
                label: Text(
                  '$_unreadNotifications',
                  style: textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                isLabelVisible: _unreadNotifications > 0,
                backgroundColor: AppTheme.errorColor,
                child: IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: colorScheme.secondary,
                    size: 24,
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                    );
                    // Recharger les notifications après avoir visité la page
                    _fetchNotifications();
                  },
                ),
              ),
            ),
          ],
          surfaceTintColor: Colors.transparent,
          bottom: _isLoading
              ? const PreferredSize(
                  preferredSize: Size.fromHeight(kToolbarHeight),
                  child: Center(child: LinearProgressIndicator()),
                )
              : PreferredSize(
                  preferredSize: const Size.fromHeight(45),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.black,
                      unselectedLabelColor: AppTheme.subTextColor,
                      labelStyle: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                      unselectedLabelStyle: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: tabs,
                    ),
                  ),
                ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chargement de la messagerie...',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.subTextColor,
                        ),
                      ),
                    ],
                  ),
                )
              : TabBarView(children: tabViews),
        ),
      ),
    );
  }
}

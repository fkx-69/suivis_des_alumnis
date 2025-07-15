import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:memoire/screens/event/event_list_screen.dart';
import 'package:memoire/screens/event/my_events_screen.dart';
import 'package:memoire/screens/event/create_event_screen.dart';

class EventsMainScreen extends StatefulWidget {
  const EventsMainScreen({super.key});

  @override
  State<EventsMainScreen> createState() => _EventsMainScreenState();
}

class _EventsMainScreenState extends State<EventsMainScreen> with TickerProviderStateMixin {
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
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _navigateToCreateEvent(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateEventScreen()),
    );
    if (result == true) {
      // Optionnel : ajouter une logique de rafraîchissement si besoin
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundColor,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            'Événements',
            style: textTheme.titleLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          surfaceTintColor: Colors.transparent,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Bouton créer un événement
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToCreateEvent(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      icon: Icon(
                        Icons.add,
                        color: Colors.black,
                        size: 18,
                      ),
                      label: Text(
                        "Créer un événement",
                        style: textTheme.labelMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // TabBar stylisé
                  Container(
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
                        fontSize: 11,
                      ),
                      unselectedLabelStyle: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Tous les événements'),
                        Tab(text: 'Mes événements'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: const TabBarView(
            children: [
              EventListScreen(),
              MyEventsScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

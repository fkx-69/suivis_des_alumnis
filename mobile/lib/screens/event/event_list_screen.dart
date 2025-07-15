import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import 'event_detail_screen.dart';
import '../../widgets/event/event_list_view.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> with TickerProviderStateMixin {
  final _service = EventService();
  List<EventModel> _events = [];
  bool _loading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _loadEvents();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final fetched = await _service.fetchCalendar();
    final now = DateTime.now();
    final upcomingValidated = fetched
        .where((e) => e.dateDebut.isAfter(now) && e.valide)
        .toList();
    if (mounted) {
      setState(() {
        _events = upcomingValidated;
        _loading = false;
      });
      _fadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
            ),
            const SizedBox(height: 16),
            Text(
              'Chargement des événements...',
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.subTextColor,
              ),
            ),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_outlined,
              size: 64,
              color: AppTheme.subTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun événement à venir',
              style: textTheme.titleMedium?.copyWith(
                color: AppTheme.subTextColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Soyez le premier à créer un événement !',
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.subTextColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadEvents,
        color: colorScheme.secondary,
        child: EventListView(
          events: _events,
          onEventTap: (e) async {
            final modified = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => EventDetailScreen(event: e),
              ),
            );
            if (modified == true) await _loadEvents();
          },
        ),
      ),
    );
  }
}

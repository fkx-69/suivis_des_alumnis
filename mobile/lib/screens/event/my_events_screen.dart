import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import 'edit_event_screen.dart';
import 'event_detail_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> with TickerProviderStateMixin {
  late Future<List<EventModel>> _myEventsFuture;
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
    _fadeController.forward(); // 👈 essentiel pour afficher l'animation
    _myEventsFuture = EventService().fetchMyEvents();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _refreshEvents() {
    if (!mounted) return;
    setState(() {
      _myEventsFuture = EventService().fetchMyEvents();
    });
  }

  Future<void> _deleteEvent(int eventId) async {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Supprimer l\'événement ?',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ) ??
              const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Cette action est irréversible.',
          style: textTheme.bodyMedium?.copyWith(color: AppTheme.subTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Annuler',
              style: textTheme.labelLarge?.copyWith(
                color: AppTheme.subTextColor,
              ) ??
                  const TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Supprimer',
              style: textTheme.labelLarge?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ) ??
                  const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (ok == true) {
      try {
        await EventService().deleteEvent(eventId);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.successColor,
            content: Text(
              'Événement supprimé avec succès',
              style: textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        _refreshEvents();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.errorColor,
            content: Text(
              'Erreur lors de la suppression : $e',
              style: textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _navigateToEditScreen(EventModel event) async {
    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditEventScreen(event: event)),
    );
    if (result == true) {
      _refreshEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () async => _refreshEvents(),
      color: colorScheme.secondary,
      child: FutureBuilder<List<EventModel>>(
        future: _myEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur de chargement : ${snapshot.error}',
                style: textTheme.bodyMedium ?? const TextStyle(color: Colors.red),
              ),
            );
          }

          final events = snapshot.data?.where((e) => e.dateDebut.isAfter(DateTime.now())).toList() ?? [];

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun événement à venir',
                    style: textTheme.titleMedium ?? const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vous n\'avez pas encore créé d\'événement futur.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshEvents,
                    child: const Text('Actualiser'),
                  ),
                ],
              ),
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventDetailScreen(event: event),
                        ),
                      );
                    },
                    contentPadding: const EdgeInsets.all(20),
                    title: Text(
                      event.titre,
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: colorScheme.secondary),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat.yMMMd('fr_FR').add_Hm().format(event.dateDebut),
                              style: textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: event.valide
                                ? AppTheme.successColor.withOpacity(0.1)
                                : AppTheme.warningColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: event.valide
                                  ? AppTheme.successColor.withOpacity(0.3)
                                  : AppTheme.warningColor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                event.valide ? Icons.check_circle_outline : Icons.schedule,
                                size: 14,
                                color: event.valide ? AppTheme.successColor : AppTheme.warningColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                event.valide ? 'Validé' : 'En attente',
                                style: textTheme.labelSmall?.copyWith(
                                  color: event.valide ? AppTheme.successColor : AppTheme.warningColor,
                                  fontWeight: FontWeight.w600,
                                ) ??
                                    const TextStyle(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    trailing: event.valide
                        ? null
                        : PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _navigateToEditScreen(event);
                        } else if (value == 'delete') {
                          _deleteEvent(event.id);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Modifier'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Supprimer'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

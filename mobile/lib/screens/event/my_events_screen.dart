import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import 'edit_event_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  late Future<List<EventModel>> _myEventsFuture;

  @override
  void initState() {
    super.initState();
    _myEventsFuture = EventService().fetchMyEvents();
  }

  void _refreshEvents() {
    if (!mounted) return;
    setState(() {
      _myEventsFuture = EventService().fetchMyEvents();
    });
  }

  Future<void> _deleteEvent(int eventId) async {
    try {
      await EventService().deleteEvent(eventId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Événement supprimé avec succès')),
      );
      _refreshEvents();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la suppression : $e')),
      );
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
    return RefreshIndicator(
      onRefresh: () async => _refreshEvents(),
      child: FutureBuilder<List<EventModel>>(
        future: _myEventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          final events = snapshot.data?.where((e) => e.dateDebut.isAfter(DateTime.now())).toList() ?? [];

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Vous n\'avez créé aucun événement à venir.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshEvents,
                    child: const Text('Réessayer'),
                  )
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12.0),
                  title: Text(event.titre, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(DateFormat.yMMMd('fr_FR').add_Hm().format(event.dateDebut)),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(
                          event.valide ? 'Validé' : 'En attente',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: event.valide ? Colors.green : Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
          );
        },
      ),
    );
  }
}

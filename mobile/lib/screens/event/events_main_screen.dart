import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/screens/event/event_list_screen.dart';
import 'package:memoire/screens/event/my_events_screen.dart';
import 'package:memoire/screens/event/create_event_screen.dart';

class EventsMainScreen extends StatelessWidget {
  const EventsMainScreen({super.key});

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Événements', style: GoogleFonts.poppins()),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(92),
            child: Column(
              children: [
                // Bouton en haut
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ElevatedButton.icon(
                    onPressed: () => _navigateToCreateEvent(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Créer un événement"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const TabBar(
                  indicatorColor: Color(0xFF2196F3),
                  labelColor: Color(0xFF2196F3),
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(text: 'Tous les événements'),
                    Tab(text: 'Mes événements'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            EventListScreen(),
            MyEventsScreen(),
          ],
        ),
        // Supprimé : plus de FloatingActionButton
      ),
    );
  }
}

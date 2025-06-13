import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../auth/home_screen.dart';
import '../profile/profile_screen.dart';
import 'edit_event_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final service = EventService();
    const selectedIndex = 1;

    void _onNavTap(int idx) {
      switch (idx) {
        case 0:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          break;
        case 1:
          Navigator.popUntil(context, (r) => r.isFirst || r.settings.name == null);
          break;
        case 2:
          break;
        case 3:
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(event.titre),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Valider',
            onPressed: () async {
              try {
                await service.validateEvent(event.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Événement validé')),
                );
                Navigator.pop(context, true);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur validation : $e')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Modifier',
            onPressed: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => EditEventScreen(event: event)),
              );
              if (updated == true && context.mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.titre,
              style: GoogleFonts.poppins(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (event.createur != null)
            Text('Créé par : ${event.createur}',
                style: GoogleFonts.poppins()),
          const SizedBox(height: 8),
          if (event.dateDebutAffiche != null)
            Text('Début : ${event.dateDebutAffiche}',
                style: GoogleFonts.poppins(color: Colors.grey[700])),
          if (event.dateFinAffiche != null) ...[
            const SizedBox(height: 4),
            Text('Fin : ${event.dateFinAffiche}',
                style: GoogleFonts.poppins(color: Colors.grey[700])),
          ],
          const Divider(height: 32),
          Text(event.description, style: GoogleFonts.poppins(fontSize: 16)),
        ]),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/event_model.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../profile/profile_screen.dart';
import 'package:memoire/home_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {

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
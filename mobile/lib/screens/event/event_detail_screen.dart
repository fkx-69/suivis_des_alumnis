import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';

class EventDetailScreen extends StatelessWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE dd MMMM yyyy à HH:mm', 'fr_FR');

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'évènement', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Image
            if (event.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  event.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            const SizedBox(height: 16),

            // 📝 Titre
            Text(
              event.titre,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // 👤 Créateur
            if (event.createur != null)
              Text('Organisé par : ${event.createur}',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),

            // 📅 Dates
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Du ${dateFormat.format(event.dateDebut)}\nau ${dateFormat.format(event.dateFin)}',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ],
            ),

            // ✅ Statut
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.check_circle_outline, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  event.valide ? 'Validé par l\'administration' : 'En attente de validation',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: event.valide ? Colors.teal : Colors.orange,
                  ),
                ),
              ],
            ),

            // 📖 Description
            const SizedBox(height: 24),
            Text(
              'Description',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              event.description,
              style: GoogleFonts.poppins(fontSize: 15),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParcoursSection extends StatelessWidget {
  final List<Map<String, dynamic>> parcoursAcademiques;
  final List<Map<String, dynamic>> parcoursProfessionnels;
  final VoidCallback? onAdd;    // ← rendre optionnel
  final VoidCallback? onEdit;   // ← rendre optionnel

  const ParcoursSection({
    Key? key,
    required this.parcoursAcademiques,
    required this.parcoursProfessionnels,
    this.onAdd,                 // ← pas required
    this.onEdit,                // ← pas required
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF4CAF50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bouton Ajouter (uniquement si onAdd != null)
        if (onAdd != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 20),
              label: Text("Ajouter un parcours",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: onAdd,
            ),
          ),

        // … reste de ton build (ExpansionTile pour académique et pro) …

        // Bouton Modifier (uniquement si onEdit != null)
        if (onEdit != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextButton.icon(
              icon: const Icon(Icons.edit, color: Colors.grey),
              label: Text("Modifier", style: GoogleFonts.poppins(color: Colors.grey[800])),
              onPressed: onEdit,
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'parcours_display_section.dart';

class ParcoursSection extends StatelessWidget {
  final List<Map<String, dynamic>> parcoursAcademiques;
  final List<Map<String, dynamic>> parcoursProfessionnels;
  final VoidCallback? onAdd;
  final VoidCallback? onEdit;

  const ParcoursSection({
    Key? key,
    required this.parcoursAcademiques,
    required this.parcoursProfessionnels,
    this.onAdd,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF4CAF50);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 Bloc académique déroulant
        ParcoursDisplaySection(
          title: 'Parcours académiques',
          icon: Icons.school,
          items: parcoursAcademiques,
          titleField: 'intitule',
          subtitleFields: ['etablissement', 'annee_debut', 'annee_fin'],
        ),

        // 🔹 Bloc professionnel déroulant
        ParcoursDisplaySection(
          title: 'Parcours professionnels',
          icon: Icons.work,
          items: parcoursProfessionnels,
          titleField: 'intitule',
          subtitleFields: ['etablissement', 'annee_debut', 'annee_fin'],
        ),

        // 🔹 Ajout/modification si on est sur profil personnel
        if (onAdd != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: Text('Ajouter un parcours',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        if (onEdit != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextButton.icon(
              icon: const Icon(Icons.edit, color: Colors.grey),
              label: Text('Modifier',
                  style: GoogleFonts.poppins(color: Colors.grey[800])),
              onPressed: onEdit,
            ),
          ),
      ],
    );
  }
}

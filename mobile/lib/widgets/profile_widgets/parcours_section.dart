// lib/widgets/profile_widgets/parcours_section.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParcoursSection extends StatelessWidget {
  final List<Map<String, dynamic>> parcoursAcademiques;
  final List<Map<String, dynamic>> parcoursProfessionnels;
  final VoidCallback onAdd;
  final VoidCallback onEdit;

  const ParcoursSection({
    Key? key,
    required this.parcoursAcademiques,
    required this.parcoursProfessionnels,
    required this.onAdd,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF4CAF50);
    return Column(
      children: [
        // Bouton "Ajouter" en haut
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 20),
            label: Text("Ajouter un parcours", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: onAdd,
          ),
        ),

        // Parcours académique
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ExpansionTile(
              leading: Icon(Icons.school, color: accent),
              title: Text(
                "Parcours académique",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: parcoursAcademiques.isEmpty
                  ? [
                Text(
                  "Aucun parcours académique",
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                )
              ]
                  : parcoursAcademiques.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p['diplome'] ?? '',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      "${p['institution']}, ${p['annee_obtention']}"
                          "${p['mention'] != null ? "\n${p['mention']}" : ""}",
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Parcours professionnel
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ExpansionTile(
              leading: Icon(Icons.work, color: accent),
              title: Text(
                "Parcours professionnel",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: parcoursProfessionnels.isEmpty
                  ? [
                Text(
                  "Aucun parcours professionnel",
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                )
              ]
                  : parcoursProfessionnels.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(p['poste'] ?? '',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      "${p['entreprise']} • ${p['date_debut']} (${p['type_contrat']})",
                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Bouton Modifier
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

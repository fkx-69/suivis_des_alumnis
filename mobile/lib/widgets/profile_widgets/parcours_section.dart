import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParcoursSection extends StatelessWidget {
  final List<Map<String, dynamic>> parcoursAcademiques;
  final List<Map<String, dynamic>> parcoursProfessionnels;
  final VoidCallback onAdd;
  final VoidCallback onEdit;

  const ParcoursSection({
    super.key,
    required this.parcoursAcademiques,
    required this.parcoursProfessionnels,
    required this.onAdd,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final hasAny = parcoursAcademiques.isNotEmpty || parcoursProfessionnels.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête avec titre et bouton
          Row(
            children: [
              Text(
                'Mon Parcours',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: hasAny ? onEdit : onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: Icon(hasAny ? Icons.edit : Icons.add, size: 20, color: Colors.white),
                label: Text(
                  hasAny ? 'Modifier' : 'Ajouter',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Contenu
          if (!hasAny)
            Center(
              child: Text(
                "Aucun parcours renseigné.",
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  if (parcoursAcademiques.isNotEmpty) ...[
                    Text('Académique',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    ...parcoursAcademiques.map((p) => _buildCard(p)).toList(),
                    const SizedBox(height: 16),
                  ],
                  if (parcoursProfessionnels.isNotEmpty) ...[
                    Text('Professionnel',
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    ...parcoursProfessionnels.map((p) => _buildCard(p)).toList(),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.containsKey('titre'))
              Text(
                data['titre'],
                style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            if (data.containsKey('description'))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  data['description'],
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

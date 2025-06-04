import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParcoursSection extends StatelessWidget {
  final List<Map<String, dynamic>> parcoursAcademiques;
  final List<Map<String, dynamic>> parcoursProfessionnels;
  final VoidCallback onAdd;     // à appeler pour "Ajouter Parcours"
  final VoidCallback onEdit;    // à appeler pour "Modifier Parcours"

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

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mon Parcours',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // Boutons d'action
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: hasAny ? onEdit : onAdd,
                  icon: Icon(hasAny ? Icons.edit : Icons.add),
                  label: Text(hasAny ? 'Modifier Parcours' : 'Ajouter Parcours'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Liste déroulante
            Expanded(
              child: hasAny
                  ? ListView(
                children: [
                  if (parcoursAcademiques.isNotEmpty) ...[
                    Text('Académique',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    ...parcoursAcademiques.map((p) => _buildCard(p)).toList(),
                    const SizedBox(height: 16),
                  ],
                  if (parcoursProfessionnels.isNotEmpty) ...[
                    Text('Professionnel',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    ...parcoursProfessionnels.map((p) => _buildCard(p)).toList(),
                  ],
                ],
              )
                  : Center(
                child: Text(
                  "Aucun parcours n'a encore été renseigné.",
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (data.containsKey('titre'))
              Text(data['titre'],
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
            if (data.containsKey('description'))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(data['description'],
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParcoursDisplaySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Map<String, dynamic>> items;
  final String titleField;
  final List<String> subtitleFields;
  final Color? accentColor;

  const ParcoursDisplaySection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.titleField,
    required this.subtitleFields,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? const Color(0xFF4CAF50); // Default green

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: ExpansionTile(
          leading: Icon(icon, color: color),
          iconColor: color,
          collapsedIconColor: color,
          title: Text(
            title,
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: items.isEmpty
              ? [
            Text(
              "Aucun élément",
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            )
          ]
              : items.map((item) {
            final titleText = item[titleField]?.toString() ?? 'Sans titre';

            final List<String> parts = [];
            for (final field in subtitleFields) {
              if (item.containsKey(field) && item[field] != null) {
                parts.add(item[field].toString());
              }
            }

            final debut = item['annee_debut']?.toString();
            final fin = item['annee_fin']?.toString();
            if (debut != null && fin != null) {
              parts.add('$debut – $fin');
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  titleText,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: parts.isEmpty
                    ? null
                    : Text(
                  parts.join(' • '),
                  style: GoogleFonts.poppins(color: Colors.grey[700]),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParcoursDisplaySection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Map<String, dynamic>> items;
  final String titleField;
  final List<String> subtitleFields;

  const ParcoursDisplaySection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.titleField,
    required this.subtitleFields,
  });

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF4CAF50);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: ExpansionTile(
          leading: Icon(icon, color: accent),
          title: Text(title,
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: items.isEmpty
              ? [
            Text(
              "Aucun élément",
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            )
          ]
              : items.map((item) {
            final subtitle = subtitleFields
                .map((f) => item[f]?.toString() ?? '')
                .where((s) => s.isNotEmpty)
                .join(' • ');
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item[titleField] ?? '',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text(subtitle,
                    style: GoogleFonts.poppins(color: Colors.grey[700])),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

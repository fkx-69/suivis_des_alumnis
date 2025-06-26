// lib/widgets/group/message_bubble.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageBubble extends StatelessWidget {
  final String auteur;
  final String contenu;
  final String date;
  final bool alignRight;

  const MessageBubble({
    Key? key,
    required this.auteur,
    required this.contenu,
    required this.date,
    this.alignRight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = alignRight ? Colors.green.shade100 : Colors.grey.shade200;
    final align = alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = alignRight
        ? const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomLeft: Radius.circular(12))
        : const BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
        bottomRight: Radius.circular(12));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bg, borderRadius: radius),
            child: Column(
              crossAxisAlignment: align,
              children: [
                Text(auteur, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(contenu, style: GoogleFonts.poppins(fontSize: 14)),
                const SizedBox(height: 4),
                Text(date, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

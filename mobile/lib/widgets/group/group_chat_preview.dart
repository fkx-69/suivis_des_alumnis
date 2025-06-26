// lib/widgets/group/group_chat_preview.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupChatPreview extends StatelessWidget {
  final String nom;
  final String dernierMessage;
  final String date;
  final VoidCallback onTap;

  const GroupChatPreview({
    Key? key,
    required this.nom,
    required this.dernierMessage,
    required this.date,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(child: Text(nom[0].toUpperCase())),
      title: Text(nom, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      subtitle: Text(dernierMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Text(date, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
    );
  }
}

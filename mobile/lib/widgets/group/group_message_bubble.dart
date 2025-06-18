// lib/widgets/group/group_message_bubble.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memoire/models/group_model.dart';

class GroupMessageBubble extends StatelessWidget {
  final GroupMessageModel message;
  final bool isMine;

  const GroupMessageBubble({
    super.key,
    required this.message,
    this.isMine = false,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat.Hm().format(message.dateEnvoi);
    final bgColor = isMine
        ? const Color(0xFF4CAF50).withOpacity(0.1)
        : Colors.grey.shade200;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.auteurUsername,
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message.message,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: Colors.grey[600]
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// lib/widgets/group/group_chat_input.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const GroupChatInput({
    super.key,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: 'Écrire un message…',
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Color(0xFF2196F3)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: onSend,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.send, color: const Color(0xFF2196F3)),
            ),
          ),
        ],
      ),
    );
  }
}

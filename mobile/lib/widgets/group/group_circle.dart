// lib/widgets/group/group_circle.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupCircle extends StatelessWidget {
  final String nom;
  final bool isMember;
  final VoidCallback? onJoin;
  final VoidCallback? onTap;

  const GroupCircle({
    Key? key,
    required this.nom,
    this.isMember = false,
    this.onJoin,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: isMember ? Colors.green.shade300 : Colors.grey.shade300,
            child: Text(
              nom[0].toUpperCase(),
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              nom,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ),
          if (!isMember && onJoin != null)
            TextButton(
              onPressed: onJoin,
              child: const Text('Rejoindre', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

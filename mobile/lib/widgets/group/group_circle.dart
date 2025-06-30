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
    final displayName = nom.length > 10 ? '${nom.substring(0, 10)}…' : nom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(40),
          child: CircleAvatar(
            radius: 32,
            backgroundColor:
            isMember ? Colors.green.shade400 : Colors.grey.shade300,
            child: Text(
              nom[0].toUpperCase(),
              style: const TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 70,
          child: Text(
            displayName,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        if (!isMember && onJoin != null) ...[
          const SizedBox(height: 4),
          SizedBox(
            height: 28,
            child: OutlinedButton(
              onPressed: onJoin,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(64, 28),
                side: BorderSide(color: Theme.of(context).primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Rejoindre',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

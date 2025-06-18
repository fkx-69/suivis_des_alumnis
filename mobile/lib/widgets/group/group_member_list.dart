// lib/widgets/group/group_member_list.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/models/group_model.dart';

class GroupMemberList extends StatelessWidget {
  final List<GroupMemberModel> members;

  const GroupMemberList({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Center(
        child: Text(
          'Aucun membre',
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: members.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final m = members[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: Text(
              m.username.substring(0,1).toUpperCase(),
              style: GoogleFonts.poppins(color: Colors.grey[800]),
            ),
          ),
          title: Text(
            m.username,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            m.role ?? '',
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 13),
          ),
        );
      },
    );
  }
}

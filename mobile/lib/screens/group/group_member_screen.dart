// lib/screens/group/group_members_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/models/group_model.dart';
import 'package:memoire/services/group_service.dart';

class GroupMembersScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  const GroupMembersScreen({
    Key? key,
    required this.groupId,
    required this.groupName,
  }) : super(key: key);

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {
  final _svc = GroupeService();
  bool _loading = true;
  String? _error;
  List<GroupMemberModel> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _members = await _svc.fetchMembers(widget.groupId);
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Membres — ${widget.groupName}',
            style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadMembers,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
          child: Text('Erreur : $_error',
              style: GoogleFonts.poppins(color: Colors.red)),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: _members.length,
          itemBuilder: (_, i) {
            final m = _members[i];
            return ListTile(
              leading: CircleAvatar(
                child: Text(m.username[0].toUpperCase()),
              ),
              title: Text(m.username,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600)),
              subtitle: Text(
                [m.prenom, m.nom]
                    .where((s) => s != null && s.isNotEmpty)
                    .join(' '),
                style: GoogleFonts.poppins(),
              ),
            );
          },
        ),
      ),
    );
  }
}

// lib/screens/group/group_list_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/models/group_model.dart';
import 'package:memoire/services/group_service.dart';
import 'package:memoire/widgets/group/group_circle.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({Key? key}) : super(key: key);
  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final GroupeService _svc = GroupeService();
  bool _loading = true;
  String? _error;
  List<GroupModel> _allGroups = [];

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _allGroups = await _svc.fetchGroups();
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
        title: Text('Groupes', style: GoogleFonts.poppins()),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add),
            onPressed: () async {
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
              );
              if (created == true) _loadGroups();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadGroups,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
          child: Text('Erreur : $_error',
              style: GoogleFonts.poppins(color: Colors.red)),
        )
            : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final horizontaux = _allGroups;
    final verticaux = _allGroups.where((g) => g.isMember).toList();

    return Column(
      children: [
        // on passe la hauteur à 150 pour ne plus overflow
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: horizontaux.length,
            itemBuilder: (_, i) {
              final g = horizontaux[i];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GroupCircle(
                  nom: g.nomGroupe,
                  isMember: g.isMember,
                  onTap: g.isMember
                      ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupDetailScreen(group: g),
                    ),
                  ).then((r) {
                    if (r == true) _loadGroups();
                  })
                      : null,
                  onJoin: g.isMember
                      ? null
                      : () async {
                    await _svc.joinGroup(g.id);
                    await _loadGroups();
                  },
                ),
              );
            },
          ),
        ),

        const Divider(height: 1),

        Expanded(
          child: verticaux.isEmpty
              ? Center(
            child: Text(
              'Vous n’êtes membre d’aucun groupe.',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: verticaux.length,
            itemBuilder: (_, i) {
              final g = verticaux[i];
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => GroupDetailScreen(group: g)),
                  ).then((r) {
                    if (r == true) _loadGroups();
                  }),
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor:
                            const Color(0xFF2196F3).withOpacity(.2),
                            child: Text(
                              g.nomGroupe[0].toUpperCase(),
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  color: const Color(0xFF2196F3)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(g.nomGroupe,
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text(
                                  g.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

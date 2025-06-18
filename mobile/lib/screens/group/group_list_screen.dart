// lib/screens/group/group_list_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/models/group_model.dart';
import 'package:memoire/services/group_service.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final _service = GroupeService();
  List<GroupModel> _groups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    setState(() => _loading = true);
    // TODO: ajouter getAllGroups() dans GroupeService
    final fetched = await _service.getAllGroups();
    setState(() {
      _groups = fetched;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient header
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Groupes',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              centerTitle: true,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                  final g = _groups[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Material(
                      color: Colors.white,
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GroupDetailScreen(group: g),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(g.nomGroupe,
                                  style: GoogleFonts.poppins(
                                      fontSize: 18, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text(
                                g.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: _groups.length,
              ),
            ),
        ],
      ),

      // FAB pour créer un nouveau groupe
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          );
          if (created == true) _loadGroups();
        },
        child: const Icon(Icons.group_add),
      ),
    );
  }
}

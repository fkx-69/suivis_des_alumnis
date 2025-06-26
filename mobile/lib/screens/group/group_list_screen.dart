// lib/screens/group/group_list_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/models/group_model.dart';
import 'package:memoire/services/group_service.dart';
import 'package:memoire/services/auth_service.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});
  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  final _svc    = GroupeService();
  final _auth   = AuthService();

  late final int _userId;
  List<GroupModel>       _allGroups    = [];
  Set<int>               _memberGroupIds = {};
  bool                   _loading      = true;

  @override
  void initState() {
    super.initState();
    _initEverything();
  }

  Future<void> _initEverything() async {
    setState(() => _loading = true);
    // 1) récupération user courant
    final user = await _auth.getUserInfo();
    _userId = user.id;

    // 2) tous les groupes
    _allGroups = await _svc.fetchGroups();

    // 3) membership pour chacun
    final futures = _allGroups.map((g) async {
      try {
        final members = await _svc.fetchMembers(g.id);
        if (members.any((m) => m.id == _userId)) {
          _memberGroupIds.add(g.id);
        }
      } catch (_) {/* si erreur, on considère non-membre */}
    }).toList();
    await Future.wait(futures);

    setState(() => _loading = false);
  }

  Future<void> _join(int groupId) async {
    await _svc.joinGroup(groupId);
    setState(() => _memberGroupIds.add(groupId));
  }

  @override
  Widget build(BuildContext context) {
    // En cas de chargement, spinner plein écran
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Sépare horizontal vs vertical
    final horizontaux = _allGroups;
    final verticaux   = _allGroups.where((g) => _memberGroupIds.contains(g.id)).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ----------------------------------------------------------------
            // 1) Scroll horizontal "stories"
            // ----------------------------------------------------------------
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: horizontaux.length,
                itemBuilder: (ctx, i) {
                  final g = horizontaux[i];
                  final isMember = _memberGroupIds.contains(g.id);
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: isMember
                              ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDetailScreen(group: g),
                            ),
                          ).then((r) {
                            // si on retourne "true" (quitte/rejoin), on reteste
                            if (r == true) _initEverything();
                          })
                              : null,
                          borderRadius: BorderRadius.circular(40),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Color(0xFF2196F3).withOpacity(.2),
                            child: Text(
                              g.nomGroupe.substring(0,1).toUpperCase(),
                              style: GoogleFonts.poppins(fontSize: 24, color: Color(0xFF2196F3)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 64,
                          child: Text(
                            g.nomGroupe,
                            style: GoogleFonts.poppins(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (!isMember)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: OutlinedButton(
                              onPressed: () async {
                                await _join(g.id);
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(64, 28),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Text('Rejoindre', style: TextStyle(fontSize: 10)),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // ----------------------------------------------------------------
            // 2) Liste verticale des discussions (seulement les membres)
            // ----------------------------------------------------------------
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
                itemBuilder: (ctx, i) {
                  final g = verticaux[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Material(
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
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Color(0xFF2196F3).withOpacity(.2),
                                child: Text(
                                  g.nomGroupe[0].toUpperCase(),
                                  style: GoogleFonts.poppins(
                                      fontSize: 20, color: Color(0xFF2196F3)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(g.nomGroupe,
                                        style: GoogleFonts.poppins(
                                            fontSize: 16, fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(
                                      g.description,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(color: Colors.grey[700]),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey),
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
        ),
      ),

      // ----------------------------------------------------------------
      // FAB pour créer un nouveau groupe
      // ----------------------------------------------------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          );
          if (created == true) _initEverything();
        },
        child: const Icon(Icons.group_add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/parcours_service.dart';
import '../../widgets/profile_widgets/profile_header.dart';
import '../../widgets/profile_widgets/user_info_card.dart';
import '../../widgets/profile_widgets/parcours_display_section.dart';

class PublicProfileScreen extends StatefulWidget {
  final String username;
  const PublicProfileScreen({super.key, required this.username});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final AuthService _auth         = AuthService();
  final ParcoursService _parcours = ParcoursService();

  UserModel? _user;
  bool _isUserLoading     = true;
  bool _isParcoursLoading = true;

  List<Map<String, dynamic>> _parcoursA = [];
  List<Map<String, dynamic>> _parcoursP = [];

  @override
  void initState() {
    super.initState();
    _loadPublicProfile();
  }

  Future<void> _loadPublicProfile() async {
    setState(() {
      _isUserLoading = true;
      _isParcoursLoading = true;
    });

    try {
      // 1) User public
      final u = await _auth.fetchPublicProfile(widget.username);
      if (!mounted) return;
      setState(() => _user = u);

      // 2) Parcours publics
      final a = await _parcours.getParcoursAcademiquesPublic(widget.username);
      final p = await _parcours.getParcoursProfessionnelsPublic(widget.username);
      if (!mounted) return;
      setState(() {
        _parcoursA = a;
        _parcoursP = p;
        _isParcoursLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUserLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUserLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_user == null) {
      return const Scaffold(body: Center(child: Text('Profil introuvable')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('@${_user!.username}'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ProfileHeader(user: _user!),
          const SizedBox(height: 16),
          UserInfoCard(user: _user!),
          const SizedBox(height: 24),

          // Actions (message / mentorat / signaler)…
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Envoyer un message'),
                  onPressed: () => _auth.sendMessage(toUsername: widget.username, contenu: ''),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.group_add_outlined),
                  label: const Text('Demande de mentorat'),
                  onPressed: () => _auth.sendMentorshipRequest(userId: _user!.id, message: null),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.report_gmailerrorred),
                  label: const Text('Signaler ce compte'),
                  onPressed: () => _auth.reportUser(reportedUserId: _user!.id, reason: ''),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Parcours publics (collapsibles)
          if (_isParcoursLoading)
            const Center(child: CircularProgressIndicator())
          else ...[
            ParcoursDisplaySection(
              title: 'Parcours académique',
              icon: Icons.school,
              items: _parcoursA,
              titleField: 'diplome',
              subtitleFields: ['institution', 'annee_obtention', 'mention'],
            ),
            ParcoursDisplaySection(
              title: 'Parcours professionnel',
              icon: Icons.work,
              items: _parcoursP,
              titleField: 'poste',
              subtitleFields: ['entreprise', 'date_debut', 'type_contrat'],
            ),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

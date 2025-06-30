// lib/screens/profile/public_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/profile_widgets/profile_header.dart';
import '../../widgets/profile_widgets/user_info_card.dart';
import '../../widgets/profile_widgets/parcours_section.dart';

class PublicProfileScreen extends StatefulWidget {
  final String username;
  const PublicProfileScreen({Key? key, required this.username})
      : super(key: key);

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final AuthService _auth = AuthService();

  bool _isLoading = true;
  Map<String, dynamic>? _profileJson;
  late UserModel _userModel;
  late List<Map<String, dynamic>> _acad;
  late List<Map<String, dynamic>> _prof;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final json =
      await _auth.fetchPublicAlumniByUsername(widget.username);
      if (!mounted) return;

      // 1) extraire et construire UserModel
      final userMap =
      Map<String, dynamic>.from(json['user'] as Map<String, dynamic>);
      _userModel = UserModel.fromJson(userMap);

      // 2) extraire parcours
      _acad = List<Map<String, dynamic>>.from(
          json['parcours_academiques'] as List<dynamic>? ?? []);
      _prof = List<Map<String, dynamic>>.from(
          json['parcours_professionnels'] as List<dynamic>? ?? []);

      // injecter user_id pour signalement / mentorat
      _profileJson = {
        ...json,
        'user_id': userMap['id'] as int,
      };
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final contenu = await showDialog<String>(
      context: context,
      builder: (_) => _TextEntryDialog(
        title: 'Envoyer un message',
        hint: 'Votre message…',
      ),
    );
    if (contenu == null || contenu.trim().isEmpty) return;

    try {
      await _auth.sendMessage(
        toUsername: widget.username,
        contenu: contenu.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message envoyé')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Future<void> _requestMentorat() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Demande de mentorat', style: GoogleFonts.poppins()),
        content: Text(
          'Envoyer une demande de mentorat à @${widget.username} ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    try {
      final userId = _profileJson!['user_id'] as int;
      await _auth.sendMentorshipRequest(
        userId: userId,
        message: null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande de mentorat envoyée')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  Future<void> _reportUser() async {
    final raison = await showDialog<String>(
      context: context,
      builder: (_) => _TextEntryDialog(
        title: 'Signaler ce compte',
        hint: 'Raison du signalement…',
      ),
    );
    if (raison == null || raison.trim().isEmpty) return;

    try {
      final userId = _profileJson!['user_id'] as int;
      await _auth.reportUser(
        reportedUserId: userId,
        reason: raison.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Compte signalé')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_profileJson == null) {
      return const Scaffold(
        body: Center(child: Text('Profil introuvable')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('@${_userModel.username}'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2196F3)),
        titleTextStyle: GoogleFonts.poppins(
          color: const Color(0xFF2196F3),
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.report, color: Colors.redAccent),
            onPressed: _reportUser,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        color: const Color(0xFF4CAF50),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            ProfileHeader(user: _userModel),
            const SizedBox(height: 16),

            // actions sous le nom
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Message'),
                      onPressed: _sendMessage,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.group_add_outlined),
                      label: const Text('Mentorat'),
                      onPressed: _requestMentorat,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: UserInfoCard(user: _userModel),
            ),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Parcours',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 12),

            ParcoursSection(
              parcoursAcademiques: _acad,
              parcoursProfessionnels: _prof,
              onAdd: null,
              onEdit: null,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _TextEntryDialog extends StatefulWidget {
  final String title;
  final String hint;
  const _TextEntryDialog({required this.title, required this.hint});

  @override
  State<_TextEntryDialog> createState() => _TextEntryDialogState();
}

class _TextEntryDialogState extends State<_TextEntryDialog> {
  final TextEditingController _ctl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title, style: GoogleFonts.poppins()),
      content: TextField(
        controller: _ctl,
        maxLines: 4,
        decoration: InputDecoration(
          hintText: widget.hint,
          border: const OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
        ElevatedButton(onPressed: () => Navigator.pop(context, _ctl.text), child: const Text('Envoyer')),
      ],
    );
  }
}

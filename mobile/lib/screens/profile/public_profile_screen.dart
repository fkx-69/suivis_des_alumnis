import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/models/mentorship_request_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/messaging_service.dart';
import '../../widgets/profile_widgets/parcours_display_section.dart';
import '../../widgets/profile_widgets/user_info_card.dart';
import '../../models/publication_model.dart';
import '../../services/publication_service.dart';
import '../../widgets/publication_card.dart';
import 'package:dio/dio.dart';
import '../messaging/chat_screen.dart';

class PublicProfileScreen extends StatefulWidget {
  final String username;

  const PublicProfileScreen({
    super.key,
    required this.username,
  });

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  final AuthService _auth = AuthService();
  final MessagingService _messaging = MessagingService();
  bool _isLoading = true;
  UserModel? _user;
  List<Map<String, dynamic>> _acad = [];
  List<Map<String, dynamic>> _prof = [];
  List<PublicationModel> _publications = [];
  final PublicationService _publicationService = PublicationService();
  MentorshipRequestModel? _existingRequest;
  bool _isRequestLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isRequestLoading = true;
    });

    try {
      // On commence par charger l'utilisateur (sans parcours)
      final user = await _auth.fetchPublicProfile(widget.username);

      if (user.role.toLowerCase() == 'alumni') {
        // Cas ALUMNI → on charge tout
        final profileDataFuture = _auth.fetchCompleteAlumniProfile(widget.username);
        final publicationsFuture = _publicationService.fetchFeed();
        final requestsFuture = _messaging.fetchMyMentorshipRequests();

        final results = await Future.wait([
          profileDataFuture,
          publicationsFuture,
          requestsFuture,
        ]);

        final profileData = results[0] as Map<String, dynamic>;
        final allPublications = results[1] as List<PublicationModel>;
        final allRequests = results[2] as List<MentorshipRequestModel>;

        if (!mounted) return;

        setState(() {
          _user = profileData['user'];
          _acad = profileData['parcours_academiques'];
          _prof = profileData['parcours_professionnels'];
          _publications = allPublications
              .where((p) => p.auteur.toLowerCase() == widget.username.toLowerCase())
              .toList();
          _existingRequest = allRequests
              .where((req) => req.mentor.username.toLowerCase() == widget.username.toLowerCase())
              .cast<MentorshipRequestModel?>()
              .firstOrNull;
        });
      } else {
        // Cas ÉTUDIANT → on garde seulement les infos de base + publications
        final allPublications = await _publicationService.fetchFeed();
        if (!mounted) return;

        setState(() {
          _user = user;
          _acad = [];
          _prof = [];
          _publications = allPublications
              .where((p) => p.auteur.toLowerCase() == widget.username.toLowerCase())
              .toList();
          _existingRequest = null; // les étudiants ne reçoivent pas de mentorat
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement du profil : $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRequestLoading = false;
        });
      }
    }
  }


  void _sendMessage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          peerUsername: widget.username,
        ),
      ),
    );
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
      await _messaging.sendMentorshipRequest(username: widget.username);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande de mentorat envoyée')),
        );
        _loadProfile(); // Refresh state
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  Future<void> _reportUser() async {
    // 1) Capturer le context avant l’await
    final ctx = context;

    // 2) Boîte de dialogue pour choisir le motif
    final String? reason = await showDialog<String>(
      context: ctx,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Signaler @${_user?.username ?? 'utilisateur'}'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'comportement_inapproprié'),
              child: Text('Comportement inapproprié'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'contenu_inapproprié'),
              child: Text('Contenu inapproprié'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'autre'),
              child: Text('Autre'),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
            ),
          ],
        );
      },
    );
    if (reason == null) return; // l'utilisateur a annulé

    // 3) Vérifier que _user est bien chargé
    if (_user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text("Impossible de signaler : utilisateur introuvable."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 4) On peut déballer _user en toute sécurité
    final user = _user!;

    // 5) Appel au service
    try {
      await _auth.reportUser(
        reportedUserId: user.id,  // id est non-nullable dans UserModel
        reason: reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Utilisateur signalé. Merci pour votre contribution.'),
          backgroundColor: Colors.green,
        ),
      );
    } on DioException catch (e) { // Correction: DioError -> DioException
      // Extraire un message plus lisible si possible
      String msg = 'Une erreur est survenue';
      final data = e.response?.data;
      if (data is Map && data['reported_user_id'] is List && data['reported_user_id'].isNotEmpty) {
        msg = data['reported_user_id'][0] as String;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du signalement : $msg'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('Erreur inattendue : $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text("Profil introuvable")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('@${_user!.username}'),
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
            icon: const Icon(Icons.flag_outlined),
            onPressed: _reportUser,
            tooltip: "Signaler l'utilisateur",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            _PublicHeader(user: _user!),
            const SizedBox(height: 16),
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
                  if (_user!.role.toLowerCase() == 'alumni') ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _isRequestLoading
                          ? const Center(child: CircularProgressIndicator())
                          : OutlinedButton.icon(
                              icon: const Icon(Icons.group_add_outlined),
                              label: Text(_existingRequest?.statut == 'en_attente'
                                  ? 'Demande envoyée'
                                  : _existingRequest?.statut == 'acceptee'
                                      ? 'Mentor'
                                      : 'Mentorat'),
                              onPressed: _existingRequest == null || _existingRequest?.statut == 'refusee'
                                  ? _requestMentorat
                                  : null, // Disable button if request is pending or accepted
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                              ),
                            ),
                    ),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: UserInfoCard(user: _user!),
            ),
            const SizedBox(height: 24),
            if (_user!.role.toLowerCase() == 'alumni') ...[
              ParcoursDisplaySection(
                title: "Parcours académique",
                icon: Icons.school_outlined,
                items: _acad,
                titleField: 'diplome',
                subtitleFields: ['institution', 'annee_obtention', 'mention'],
                accentColor: Colors.teal,
              ),
              ParcoursDisplaySection(
                title: "Parcours professionnel",
                icon: Icons.work_outline,
                items: _prof,
                titleField: 'poste',
                subtitleFields: ['entreprise', 'date_debut', 'type_contrat'],
                accentColor: Colors.indigo,
              ),
            ],
            const SizedBox(height: 32),

            // Section des publications
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Publications',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            if (_publications.isEmpty)
              const Center(child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Aucune publication pour le moment.'),
              ))
            else
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _publications.length,
                itemBuilder: (context, index) {
                  final publication = _publications[index];
                  return PublicationCard(publication: publication);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PublicHeader extends StatelessWidget {
  final UserModel user;
  const _PublicHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final nomComplet = '${user.prenom} ${user.nom}';
    final username = '@${user.username}';
    final image = user.photoProfil != null && user.photoProfil!.isNotEmpty
        ? NetworkImage(user.photoProfil!)
        : const AssetImage('assets/images/default_avatar.png') as ImageProvider;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          CircleAvatar(radius: 42, backgroundImage: image),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nomComplet,
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600)),
                Text(username,
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700])),
                if (user.biographie != null && user.biographie!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    user.biographie!,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[800]),
                  ),
                ]
              ],
            ),
          ),
        ],
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

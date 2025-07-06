import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/models/mentorship_request_model.dart';
import 'package:memoire/models/user_model.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/services/messaging_service.dart';

class MentorshipRequestsList extends StatefulWidget {
  const MentorshipRequestsList({super.key});

  @override
  State<MentorshipRequestsList> createState() => _MentorshipRequestsListState();
}

class _MentorshipRequestsListState extends State<MentorshipRequestsList> {
  final MessagingService _messagingService = MessagingService();
  final AuthService _authService = AuthService();
  late Future<List<MentorshipRequestModel>> _requestsFuture;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.currentUser?.id;
    _requestsFuture = _messagingService.fetchMyMentorshipRequests();
  }

  // Recharge les données et rafraîchit l'interface
  void _refreshRequests() {
    setState(() {
      _requestsFuture = _messagingService.fetchMyMentorshipRequests();
    });
  }

  Future<void> _handleResponse(MentorshipRequestModel request, String status) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    String? reason;

    if (status == 'refusee') {
      reason = await showDialog<String>(
        context: context, // Le contexte est sûr ici
        builder: (context) => _ReasonDialog(),
      );
      if (reason == null) return; // L'utilisateur a annulé
    }

    if (!mounted) return;

    try {
      await _messagingService.respondToMentorshipRequest(
        requestId: request.id,
        status: status,
        reason: reason,
      );
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Demande ${status == 'acceptee' ? 'acceptée' : 'refusée'}')),
      );
      _refreshRequests(); // Recharger les données
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return const Center(child: Text('Chargement du profil...'));
    }

    return FutureBuilder<List<MentorshipRequestModel>>(
      future: _requestsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        
        final pendingRequests = snapshot.data?.where((r) => r.statut == 'en_attente').toList();

        if (pendingRequests == null || pendingRequests.isEmpty) {
          return const Center(child: Text('Aucune demande en attente.'));
        }

        return ListView.builder(
          itemCount: pendingRequests.length,
          itemBuilder: (context, index) {
            final request = pendingRequests[index];
            final bool isSender = request.etudiant.id == _currentUserId;
            final UserModel user = isSender ? request.mentor : request.etudiant;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.profileImageUrl != null
                            ? NetworkImage(user.profileImageUrl!)
                            : null,
                        child: user.profileImageUrl == null ? const Icon(Icons.person) : null,
                      ),
                      title: Text(
                        user.username,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        request.message ?? 'Aucun message.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => _handleResponse(request, 'refusee'),
                          child: const Text('Refuser'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _handleResponse(request, 'acceptee'),
                          child: const Text('Accepter'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  @override
  _ReasonDialogState createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Motif du refus (optionnel)'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Expliquez pourquoi...'),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Confirmer le refus'),
        ),
      ],
    );
  }
}

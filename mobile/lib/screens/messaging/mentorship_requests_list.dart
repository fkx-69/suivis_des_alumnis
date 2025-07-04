import 'package:memoire/models/mentorship_request_model.dart';
import 'package:memoire/services/messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MentorshipRequestsList extends StatefulWidget {
  const MentorshipRequestsList({super.key});

  @override
  State<MentorshipRequestsList> createState() => _MentorshipRequestsListState();
}

class _MentorshipRequestsListState extends State<MentorshipRequestsList> {
  final MessagingService _messagingService = MessagingService();
  late Future<List<MentorshipRequestModel>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() {
    setState(() {
      _requestsFuture = _messagingService.fetchMyMentorshipRequests();
    });
  }

  Future<void> _handleResponse(int requestId, String status, {String? reason}) async {
    try {
      await _messagingService.respondToMentorshipRequest(requestId: requestId, status: status, reason: reason);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Demande ${status == 'acceptée' ? 'acceptée' : 'refusée'} avec succès.')),
      );
      _loadRequests(); // Recharger la liste
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  void _showRefuseDialog(int requestId) {
    final TextEditingController motifController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motif du refus (facultatif)'),
        content: TextField(
          controller: motifController,
          decoration: const InputDecoration(hintText: 'Expliquez pourquoi...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleResponse(requestId, 'refusée', reason: motifController.text);
            },
            child: const Text('Confirmer le Refus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundImage: request.utilisateur.profileImageUrl != null
                            ? NetworkImage(request.utilisateur.profileImageUrl!)
                            : null,
                        child: request.utilisateur.profileImageUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text('${request.utilisateur.prenom} ${request.utilisateur.nom}',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      subtitle: Text('@${request.utilisateur.username}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(request.message, style: GoogleFonts.poppins()),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => _showRefuseDialog(request.id), child: const Text('Refuser')),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _handleResponse(request.id, 'acceptée'),
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

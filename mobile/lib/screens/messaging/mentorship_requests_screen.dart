import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/models/mentorship_request_model.dart';
import 'package:memoire/services/messaging_service.dart';
import 'package:timeago/timeago.dart' as timeago;


class MentorshipRequestsScreen extends StatefulWidget {
  const MentorshipRequestsScreen({super.key});

  @override
  State<MentorshipRequestsScreen> createState() => _MentorshipRequestsScreenState();
}

class _MentorshipRequestsScreenState extends State<MentorshipRequestsScreen> {
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

  Future<void> _handleResponse(MentorshipRequestModel request, String status) async {
    // Store context-dependent variables before async gaps.
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    String? reason;
    if (status == 'refusee') {
      reason = await showDialog<String>(
        context: context,
        builder: (context) => _ReasonDialog(),
      );
      if (reason == null) return; // User cancelled
    }

    if (!mounted) return; // Check if the widget is still in the tree.

    try {
      await _messagingService.respondToMentorshipRequest(
        requestId: request.id,
        status: status,
        reason: reason,
      );
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Demande ${status == 'acceptee' ? 'acceptée' : 'refusée'}')),
      );
      _loadRequests(); // Refresh the list
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _loadRequests(),
        child: FutureBuilder<List<MentorshipRequestModel>>(
          future: _requestsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('Aucune demande de mentorat.'));
            }

            final requests = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _MentorshipRequestCard(
                  request: request,
                  onAccept: () => _handleResponse(request, 'acceptee'),
                  onRefuse: () => _handleResponse(request, 'refusee'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MentorshipRequestCard extends StatelessWidget {
  final MentorshipRequestModel request;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  const _MentorshipRequestCard({
    required this.request,
    required this.onAccept,
    required this.onRefuse,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = request.statut.toLowerCase() == 'en attente';
    final cardColor = isPending ? Colors.blue.shade50 : (request.statut.toLowerCase() == 'acceptee' ? Colors.green.shade50 : Colors.red.shade50);
    final statusColor = isPending ? Colors.blue : (request.statut.toLowerCase() == 'acceptee' ? Colors.green : Colors.red);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'De: @${request.utilisateur.username}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Text(
                  timeago.format(request.timestamp, locale: 'fr'),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (request.message.isNotEmpty) ...[
              Text(
                request.message,
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Text('Statut: ', style: GoogleFonts.poppins(fontSize: 14)),
                Text(
                  request.statut,
                  style: GoogleFonts.poppins(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: onRefuse,
                    child: const Text('Refuser'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accepter'),
                  ),
                ],
              )
            ]
          ],
        ),
      ),
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

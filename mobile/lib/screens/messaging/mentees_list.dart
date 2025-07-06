import 'package:memoire/models/mentorship_request_model.dart';
import 'package:memoire/screens/profile/public_profile_screen.dart';
import 'package:memoire/services/messaging_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class MenteesList extends StatefulWidget {
  const MenteesList({super.key});

  @override
  State<MenteesList> createState() => _MenteesListState();
}

class _MenteesListState extends State<MenteesList> {
  final MessagingService _messagingService = MessagingService();
  late Future<List<MentorshipRequestModel>> _menteesFuture;

  @override
  void initState() {
    super.initState();
    // On réutilise le même endpoint, mais on filtrera par statut 'acceptée'
    _menteesFuture = _messagingService.fetchMyMentorshipRequests();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MentorshipRequestModel>>(
      future: _menteesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        final acceptedRequests = snapshot.data?.where((r) => r.statut == 'acceptee').toList();

        if (acceptedRequests == null || acceptedRequests.isEmpty) {
          return const Center(child: Text('Vous n\'avez aucun mentoré pour le moment.'));
        }

        return ListView.builder(
          itemCount: acceptedRequests.length,
          itemBuilder: (context, index) {
            final mentee = acceptedRequests[index].etudiant;

            // Gérer le cas où les données du mentoré sont manquantes pour éviter les crashs.
            if (mentee == null) {
              return const Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(child: Icon(Icons.person_off)),
                  title: Text('Information du mentoré indisponible'),
                  enabled: false,
                ),
              );
            }

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: mentee.profileImageUrl != null
                      ? NetworkImage(mentee.profileImageUrl!)
                      : null,
                  child: mentee.profileImageUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text('${mentee.prenom} ${mentee.nom}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                subtitle: Text('@${mentee.username}'),
                trailing: Chip(
                  avatar: const Icon(Icons.school, size: 16),
                  label: Text('Mentoré', style: GoogleFonts.poppins()),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
                onTap: () {
                  // On s'assure que le username existe avant de naviguer.
                  if (mentee.username.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublicProfileScreen(username: mentee.username),
                      ),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}

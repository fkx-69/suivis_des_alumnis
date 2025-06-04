import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/publication_model.dart';
import 'package:memoire/services/publication_service.dart';
import '../profile_widgets/publication_form.dart';
import 'package:memoire/screens/profile/publication_detail_screen.dart';

class UserPublicationsList extends StatefulWidget {
  final String username;
  const UserPublicationsList({super.key, required this.username});

  @override
  State<UserPublicationsList> createState() => _UserPublicationsListState();
}

class _UserPublicationsListState extends State<UserPublicationsList> {
  final _service = PublicationService();
  List<PublicationModel> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    final feed = await _service.fetchFeed();
    setState(() {
      _posts = feed.where((p) => p.auteurUsername == widget.username).toList();
      _loading = false;
    });
  }

  Future<void> _confirmDelete(PublicationModel post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la publication ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _service.deletePublication(post.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publication supprimée')),
        );
        _loadPosts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
    return Column(
      children: [
        PublicationForm(onPublished: _loadPosts),
        const Divider(),
        ..._posts.map((post) => _buildPostCard(post)).toList(),
      ],
    );
  }

  Widget _buildPostCard(PublicationModel post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Texte
            if (post.texte != null && post.texte!.isNotEmpty)
              Text(post.texte!, style: GoogleFonts.poppins(fontSize: 14)),

            // Photo
            if (post.photo != null) ...[
              const SizedBox(height: 8),
              Image.network(post.photo!),
            ],

            // Vidéo
            if (post.video != null) ...[
              const SizedBox(height: 8),
              Text('Vidéo : ${post.video}', style: TextStyle(color: Colors.blue)),
            ],

            const SizedBox(height: 8),

            // Nombre de commentaires
            Text(
              '${post.commentaires.length} commentaires',
              style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
            ),

            const SizedBox(height: 8),

            // Boutons d'actions : Voir / Supprimer
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicationDetailScreen(
                          publications: _posts,
                          initialIndex: _posts.indexOf(post),
                        ),
                      ),
                    );
                  },
                  child: const Text('Voir commentaires'),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(post),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

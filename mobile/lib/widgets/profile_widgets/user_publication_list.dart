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
        title: Text('Supprimer la publication ?', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text('Cette action est irréversible.', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Annuler', style: GoogleFonts.poppins())),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Supprimer', style: GoogleFonts.poppins(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      try {
        await _service.deletePublication(post.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF4CAF50),
            content: Text('Publication supprimée', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        );
        _loadPosts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Erreur : $e', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Formulaire
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: PublicationForm(onPublished: _loadPosts),
        ),
        const SizedBox(height: 16),

        // Liste des cartes
        ..._posts.map(_buildPostCard).toList(),
      ],
    );
  }

  Widget _buildPostCard(PublicationModel post) {
    final bool hasMedia = post.photo != null || post.video != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER : avatar + username
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                      post.auteurUsername[0].toUpperCase(),
                      style: GoogleFonts.poppins(color: Colors.grey.shade800),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      post.auteurUsername,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () => _confirmDelete(post),
                  ),
                ],
              ),
            ),

            // MEDIA ou TEXTE
            if (hasMedia) ...[
              // Image ou placeholder vidéo en 1:1
              AspectRatio(
                aspectRatio: 1,
                child: post.photo != null
                    ? Image.network(post.photo!, fit: BoxFit.cover)
                    : Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Icon(Icons.videocam, size: 48, color: Colors.grey),
                  ),
                ),
              ),
            ] else ...[
              // Texte seul, style Twitter-like
              Container(
                color: Colors.grey.shade100,
                padding: const EdgeInsets.all(16),
                child: Text(
                  post.texte!,
                  style: GoogleFonts.poppins(fontSize: 15, height: 1.4),
                ),
              ),
            ],

            // CAPTION sous la media (si texte+media)
            if (hasMedia && post.texte != null && post.texte!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  post.texte!,
                  style: GoogleFonts.poppins(fontSize: 15, height: 1.4),
                ),
              ),

            const Divider(height: 1),

            // FOOTER : actions + count commentaires
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.comment, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    '${post.commentaires.length}',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicationDetailScreen(
                          publications: _posts,
                          initialIndex: _posts.indexOf(post),
                        ),
                      ),
                    ),
                    child: Text(
                      'Voir',
                      style: GoogleFonts.poppins(color: const Color(0xFF2196F3)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

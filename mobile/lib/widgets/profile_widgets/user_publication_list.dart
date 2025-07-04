import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../models/publication_model.dart';
import 'package:memoire/services/publication_service.dart';
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
    initializeDateFormatting('fr_FR', null).then((_) {
      if (mounted) {
        _loadPosts();
      }
    });
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
    if (_posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'Aucune publication pour le moment.',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Column(
      children: _posts.map((post) => _buildPostCard(post)).toList(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'à l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'il y a ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'il y a ${difference.inDays} j';
    } else {
      return DateFormat('d MMMM y', 'fr_FR').format(date);
    }
  }

  Widget _buildPostCard(PublicationModel post) {
    final bool hasMedia = post.photo != null || post.video != null;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: avatar, username, date, menu
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade300,
                child: Text(
                  post.auteurUsername[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade800, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.auteurUsername,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    Text(
                      _formatDate(post.datePublication),
                      style: GoogleFonts.poppins(
                          color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onPressed: () => _confirmDelete(post),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // TEXTE (légende)
          if (post.texte != null && post.texte!.isNotEmpty) ...[
            Text(
              post.texte!,
              style: GoogleFonts.poppins(fontSize: 15, height: 1.4),
            ),
            if (hasMedia) const SizedBox(height: 12),
          ],

          // MEDIA
          if (hasMedia)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: post.photo != null
                    ? Image.network(post.photo!, fit: BoxFit.cover)
                    : Container(
                        color: Colors.black,
                        child: const Center(
                          child: Icon(Icons.play_circle_outline,
                              size: 48, color: Colors.white),
                        ),
                      ),
              ),
            ),
          
          const Divider(height: 32),

          // FOOTER: actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.comment_outlined, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 6),
                  Text(
                    '${post.commentaires.length} Commentaire${post.commentaires.length > 1 ? 's' : ''}',
                    style: GoogleFonts.poppins(color: Colors.grey[700], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
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
                  'Voir les commentaires',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF2196F3), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

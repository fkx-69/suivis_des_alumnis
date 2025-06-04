import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/publication_model.dart';
import '../../models/comment_model.dart';
import 'package:memoire/services/publication_service.dart';

class PublicationDetailScreen extends StatefulWidget {
  final List<PublicationModel> publications;
  final int initialIndex;

  const PublicationDetailScreen({
    super.key,
    required this.publications,
    this.initialIndex = 0,
  });

  @override
  State<PublicationDetailScreen> createState() =>
      _PublicationDetailScreenState();
}

class _PublicationDetailScreenState extends State<PublicationDetailScreen> {
  late PageController _pageController;
  final PublicationService _service = PublicationService();
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.initialIndex, viewportFraction: 1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment(int pubId) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    await _service.commentPublication(pubId, text);
    setState(() {
      // Rafraîchir en récupérant de nouveau cette publication
      final idx = _pageController.page!.toInt();
      widget.publications[idx].commentaires.add(
        CommentModel(
          id: -1,
          publication: pubId,
          auteurUsername: 'Vous',
          contenu: text,
          dateCommentaire: DateTime.now(),
        ),
      );
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publication'),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.publications.length,
        itemBuilder: (context, index) {
          final post = widget.publications[index];
          return _buildDetail(post);
        },
      ),
    );
  }

  Widget _buildDetail(PublicationModel post) {
    return SafeArea(
      child: Column(
        children: [
          // Contenu multimédia
          if (post.photo != null)
            Image.network(post.photo!, width: double.infinity, fit: BoxFit.cover),
          if (post.video != null)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(
                child: Text(
                  'Vidéo: ${post.video}',
                  style: GoogleFonts.poppins(color: Colors.blue),
                ),
              ),
            ),
          if (post.texte != null && post.texte!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(post.texte!, style: GoogleFonts.poppins()),
            ),

          const Divider(),

          // Liste des commentaires
          Expanded(
            child: ListView.builder(
              itemCount: post.commentaires.length,
              itemBuilder: (context, i) {
                final c = post.commentaires[i];
                return ListTile(
                  title: Text(c.auteurUsername,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle: Text(c.contenu, style: GoogleFonts.poppins()),
                  trailing: Text(
                    "${c.dateCommentaire.hour}:${c.dateCommentaire.minute.toString().padLeft(2, '0')}",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                  ),
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Nouveau commentaire
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Ajouter un commentaire...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _addComment(post.id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

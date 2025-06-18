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
  late final PageController _pageController;
  final PublicationService _service = PublicationService();
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 1,
    );
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
    setState(() => _submitting = true);
    try {
      await _service.commentPublication(pubId, text);
      final idx = _pageController.page!.toInt();
      setState(() {
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
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: BackButton(color: const Color(0xFF2196F3)),
        title: Text(
          'Publication',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2196F3),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.publications.length,
          itemBuilder: (context, index) {
            return _buildDetail(context, widget.publications[index]);
          },
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, PublicationModel post) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    return Column(
      children: [
        // Media (photo or video placeholder)
        if (post.photo != null)
          Image.network(
            post.photo!,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          )
        else if (post.video != null)
          Container(
            width: double.infinity,
            height: 250,
            color: Colors.black12,
            child: Center(
              child: Icon(Icons.videocam, size: 64, color: Colors.grey[700]),
            ),
          ),

        // Texte de la publication
        if (post.texte != null && post.texte!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              post.texte!,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[900]),
            ),
          ),

        const Divider(height: 1),

        // Commentaires
        Expanded(
          child: post.commentaires.isEmpty
              ? Center(
            child: Text(
              'Pas encore de commentaires',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: post.commentaires.length,
            itemBuilder: (ctx, i) {
              final c = post.commentaires[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade300,
                  child: Text(
                    c.auteurUsername[0].toUpperCase(),
                    style: GoogleFonts.poppins(color: Colors.grey[800]),
                  ),
                ),
                title: Text(
                  c.auteurUsername,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(c.contenu, style: GoogleFonts.poppins()),
                trailing: Text(
                  "${c.dateCommentaire.hour.toString().padLeft(2, '0')}:${c.dateCommentaire.minute.toString().padLeft(2, '0')}",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              );
            },
          ),
        ),

        const Divider(height: 1),

        // Champ de saisie + bouton
        Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 8,
            bottom: keyboardInset > 0 ? keyboardInset : 16,
            top: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter un commentaire…',
                      hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
                      border: InputBorder.none,
                    ),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _submitting
                  ? const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF2196F3)),
                onPressed: () => _addComment(post.id),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memoire/models/publication_model.dart';
import 'package:memoire/services/publication_service.dart';
import '../models/comment_model.dart';

class PublicationCard extends StatefulWidget {
  final PublicationModel publication;

  const PublicationCard({Key? key, required this.publication}) : super(key: key);

  @override
  State<PublicationCard> createState() => _PublicationCardState();
}

class _PublicationCardState extends State<PublicationCard> {
  final TextEditingController _commentController = TextEditingController();
  final PublicationService _publicationService = PublicationService();
  bool _isCommenting = false;
  late List<CommentModel> _comments;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.publication.commentaires);
  }

  Future<void> _postComment() async {
    if (_commentController.text
        .trim()
        .isEmpty) return;
    setState(() => _isCommenting = true);

    try {
      final newComment = await _publicationService.commentPublication(
        widget.publication.id,
        _commentController.text.trim(),
      );
      setState(() {
        _comments.add(newComment);
        _commentController.clear();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCommenting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            if (widget.publication.texte != null &&
                widget.publication.texte!.isNotEmpty)
              Text(widget.publication.texte!,
                  style: GoogleFonts.poppins(fontSize: 15)),
            if (widget.publication.photo != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(widget.publication.photo!),
                ),
              ),
            const Divider(height: 24),
            _buildCommentsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          radius: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.publication.auteurUsername,
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              Text(
                DateFormat('d MMMM yyyy \'à\' HH:mm', 'fr_FR')
                    .format(widget.publication.datePublication),
                style: GoogleFonts.poppins(
                    fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Commentaires',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (_comments.isNotEmpty)
          ..._comments.map((comment) => _buildCommentTile(comment)),
        if (_comments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Aucun commentaire.',
                style: GoogleFonts.poppins(color: Colors.grey)),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  hintText: 'Ajouter un commentaire...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onSubmitted: (_) => _postComment(),
              ),
            ),
            const SizedBox(width: 8),
            _isCommenting
                ? const CircularProgressIndicator()
                : IconButton(
              icon: const Icon(Icons.send, color: Color(0xFF2196F3)),
              onPressed: _postComment,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentTile(CommentModel comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
            radius: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.auteurUsername, style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 13)),
                Text(comment.contenu, style: GoogleFonts.poppins(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
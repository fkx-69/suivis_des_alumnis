import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../models/publication_model.dart';
import '../../models/comment_model.dart';
import '../../services/publication_service.dart';
import '../../services/auth_service.dart';

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
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 1,
    );
    currentUsername = AuthService().getCurrentUsername();
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
    FocusScope.of(context).unfocus();

    try {
      final newComment = await _service.commentPublication(pubId, text);
      final pageIndex = _pageController.page?.round() ?? widget.initialIndex;

      if (mounted) {
        setState(() {
          widget.publications[pageIndex].commentaires.add(newComment);
          _commentController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(msg: 'Erreur: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _deleteComment(int pubId, int commentId) async {
    try {
      await _service.deleteComment(commentId);
      final pageIndex = _pageController.page?.round() ?? widget.initialIndex;

      if (mounted) {
        setState(() {
          widget.publications[pageIndex].commentaires.removeWhere((c) => c.id == commentId);
        });
      }
      Fluttertoast.showToast(msg: 'Commentaire supprimé');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Erreur suppression: ${e.toString()}');
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) return 'à l\'instant';
    if (difference.inMinutes < 60) return 'il y a ${difference.inMinutes} min';
    if (difference.inHours < 24) return 'il y a ${difference.inHours} h';

    return DateFormat.yMMMd('fr_FR').add_Hm().format(date);
  }

  Widget _buildCommentItem(CommentModel comment, PublicationModel post) {
    final isOwner = comment.auteurUsername == currentUsername;
    final isPostOwner = post.auteurUsername == currentUsername;
    final canDelete = isOwner || isPostOwner;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: comment.auteurPhotoProfil != null
                ? NetworkImage(comment.auteurPhotoProfil!)
                : null,
            child: comment.auteurPhotoProfil == null
                ? Text(
              comment.auteurUsername[0].toUpperCase(),
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            comment.auteurUsername,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          ),
                          if (canDelete)
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, size: 16),
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deleteComment(post.id, comment.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Supprimer'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        comment.contenu,
                        style: GoogleFonts.poppins(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    _formatDate(comment.dateCommentaire),
                    style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetail(BuildContext context, PublicationModel post) {
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    return Column(
      children: [
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

        if (post.texte != null && post.texte!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              post.texte!,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[900]),
            ),
          ),

        const Divider(height: 1),

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
              final comment = post.commentaires[i];
              return _buildCommentItem(comment, post);
            },
          ),
        ),

        const Divider(height: 1),

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
}

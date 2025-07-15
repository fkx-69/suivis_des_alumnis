import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
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

class _PublicationDetailScreenState extends State<PublicationDetailScreen> with TickerProviderStateMixin {
  late final PageController _pageController;
  final PublicationService _service = PublicationService();
  final TextEditingController _commentController = TextEditingController();
  bool _submitting = false;
  String? currentUsername;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 1,
    );
    currentUsername = AuthService().getCurrentUsername();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    _fadeController.dispose();
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    
    final isOwner = comment.auteurUsername == currentUsername;
    final isPostOwner = post.auteurUsername == currentUsername;
    final canDelete = isOwner || isPostOwner;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.surfaceColor,
              backgroundImage: comment.auteurPhotoProfil != null
                  ? NetworkImage(comment.auteurPhotoProfil!)
                  : null,
              child: comment.auteurPhotoProfil == null
                  ? Text(
                      comment.auteurUsername[0].toUpperCase(),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            comment.auteurUsername,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          if (canDelete)
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                size: 16,
                                color: AppTheme.subTextColor.withOpacity(0.7),
                              ),
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _deleteComment(post.id, comment.id);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: AppTheme.errorColor,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Supprimer',
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.errorColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        comment.contenu,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppTheme.subTextColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(comment.dateCommentaire),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.subTextColor,
                        ),
                      ),
                    ],
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    
    return Column(
      children: [
        // Media
        if (post.photo != null)
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
                post.photo!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppTheme.surfaceColor,
                    child: Icon(
                      Icons.image_not_supported,
                      color: AppTheme.subTextColor.withOpacity(0.5),
                      size: 48,
                    ),
                  );
                },
              ),
            ),
          )
        else if (post.video != null)
          Container(
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 64,
                color: Colors.white,
              ),
            ),
          ),

        // Texte
        if (post.texte != null && post.texte!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              post.texte!,
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.primaryColor,
                height: 1.5,
              ),
            ),
          ),

        const Divider(height: 1, thickness: 1),

        // Commentaires
        Expanded(
          child: post.commentaires.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 48,
                        color: AppTheme.subTextColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pas encore de commentaires',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppTheme.subTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Soyez le premier à commenter !',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.subTextColor.withOpacity(0.7),
                        ),
                      ),
                    ],
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

        const Divider(height: 1, thickness: 1),

        // Zone de saisie
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: keyboardInset > 0 ? keyboardInset + 8 : 16,
            top: 16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Ajouter un commentaire…',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.subTextColor.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                    ),
                    maxLines: null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _submitting
                  ? SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.black,
                          size: 20,
                        ),
                        onPressed: () => _addComment(post.id),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Publication',
          style: textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.publications.length,
            itemBuilder: (context, index) {
              return _buildDetail(context, widget.publications[index]);
            },
          ),
        ),
      ),
    );
  }
}

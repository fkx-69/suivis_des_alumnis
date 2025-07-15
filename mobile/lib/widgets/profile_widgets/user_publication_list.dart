import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
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

class _UserPublicationsListState extends State<UserPublicationsList> with TickerProviderStateMixin {
  final _service = PublicationService();
  List<PublicationModel> _posts = [];
  bool _loading = true;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    initializeDateFormatting('fr_FR', null).then((_) {
      if (mounted) {
        _loadPosts();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() => _loading = true);
    final feed = await _service.fetchFeed();
    setState(() {
      _posts = feed.where((p) => p.auteurUsername == widget.username).toList();
      _loading = false;
    });
    _fadeController.forward();
  }

  Future<void> _confirmDelete(PublicationModel post) async {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Supprimer la publication ?',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        content: Text(
          'Cette action est irréversible.',
          style: textTheme.bodyMedium?.copyWith(
            color: AppTheme.subTextColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Annuler',
              style: textTheme.labelLarge?.copyWith(
                color: AppTheme.subTextColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Supprimer',
              style: textTheme.labelLarge?.copyWith(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    
    if (ok == true) {
      try {
        await _service.deletePublication(post.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.successColor,
            content: Text(
              'Publication supprimée',
              style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        _loadPosts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.errorColor,
            content: Text(
              'Erreur : $e',
              style: textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (_loading) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
              ),
              const SizedBox(height: 16),
              Text(
                'Chargement des publications...',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.subTextColor,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_posts.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: AppTheme.subTextColor.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune publication pour le moment',
              style: textTheme.titleMedium?.copyWith(
                color: AppTheme.subTextColor,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Partagez vos expériences et découvertes avec la communauté',
              style: textTheme.bodyMedium?.copyWith(
                color: AppTheme.subTextColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: _posts.map((post) => _buildPostCard(post)).toList(),
      ),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final bool hasMedia = post.photo != null || post.video != null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EN-TÊTE
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.surfaceColor,
                    backgroundImage: const NetworkImage('https://via.placeholder.com/150'),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.auteurUsername,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        _formatDate(post.datePublication),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.subTextColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppTheme.subTextColor.withOpacity(0.7),
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _confirmDelete(post);
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
          ),

          // TEXTE (légende)
          if (post.texte != null && post.texte!.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.texte!,
                style: textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
            if (hasMedia) const SizedBox(height: 16),
          ],

          // MÉDIA (image ou vidéo)
          if (hasMedia) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: post.photo != null
                    ? Image.network(
                        post.photo!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: AppTheme.surfaceColor,
                            child: Icon(
                              Icons.image_not_supported,
                              color: AppTheme.subTextColor.withOpacity(0.5),
                              size: 48,
                            ),
                          );
                        },
                      )
                    : Container(
                        height: 200,
                        width: double.infinity,
                        color: AppTheme.surfaceColor,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_outline,
                              size: 48,
                              color: AppTheme.subTextColor.withOpacity(0.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Vidéo',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppTheme.subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Icône commentaires avec nombre
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicationDetailScreen(
                        publications: _posts,
                        initialIndex: _posts.indexOf(post),
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 18,
                          color: AppTheme.subTextColor.withOpacity(0.7),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${post.commentaires.length}',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppTheme.subTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

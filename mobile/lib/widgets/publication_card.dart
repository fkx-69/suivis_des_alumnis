import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:memoire/models/publication_model.dart';
import 'package:memoire/services/publication_service.dart';
import '../models/comment_model.dart';
import '../constants/app_theme.dart';
import '../constants/api_constants.dart';
import '../screens/profile/publication_detail_screen.dart';
import '../screens/profile/public_profile_screen.dart';
import 'package:memoire/services/auth_service.dart';

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
  bool _showCommentField = false;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.publication.commentaires);
    currentUsername = AuthService().getCurrentUsername(); // Si tu ne l'as pas déjà
  }

  String _buildImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      print("🔍 PublicationCard: URL d'image vide ou null");
      return '';
    }
    
    print("🔍 PublicationCard: URL originale: $imageUrl");
    
    // Si l'URL commence déjà par http, on la retourne telle quelle
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      print("🔍 PublicationCard: URL complète détectée: $imageUrl");
      return imageUrl;
    }
    
    // Sinon, on construit l'URL complète avec le baseUrl
    final baseUrl = "http://192.168.1.15:8000";
    final fullUrl = '$baseUrl$imageUrl';
    print("🔍 PublicationCard: URL construite: $fullUrl");
    return fullUrl;
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
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCommenting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final hasMedia = widget.publication.photo != null && widget.publication.photo!.isNotEmpty;
    final hasVideo = widget.publication.video != null && widget.publication.video!.isNotEmpty;

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
          // En-tête avec avatar et informations
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublicProfileScreen(
                          username: widget.publication.auteur,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppTheme.surfaceColor,
                      child: ClipOval(
                        child: _buildAuthorProfileImage() != null
                            ? Image.network(
                                _buildImageUrl(widget.publication.auteurPhotoProfil),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  print("❌ PublicationCard: Erreur chargement photo auteur: $error");
                                  return Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      color: AppTheme.primaryColor,
                                      size: 20,
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: AppTheme.primaryColor,
                                  size: 20,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PublicProfileScreen(
                                username: widget.publication.auteur,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          widget.publication.auteurUsername,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('d MMM yyyy • HH:mm', 'fr_FR').format(widget.publication.datePublication),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.subTextColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.publication.auteurUsername == currentUsername)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz,
                      color: AppTheme.subTextColor.withOpacity(0.7),
                      size: 20,
                    ),
                    onSelected: (value) async {
                      if (value == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Supprimer la publication'),
                            content: const Text('Voulez-vous vraiment supprimer cette publication ?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
                              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Supprimer')),
                            ],
                          ),
                        );
                        if (confirmed == true) {
                          await _publicationService.deletePublication(widget.publication.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Publication supprimée')),
                            );
                          }
                          // Tu peux aussi déclencher un callback pour retirer la carte
                        }
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  )

              ],
            ),
          ),

          // Contenu de la publication
          if (widget.publication.texte != null && widget.publication.texte!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.publication.texte!,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  height: 1.5,
                ),
              ),
            ),

          // Média (image ou vidéo)
          if (hasMedia || hasVideo) ...[
            const SizedBox(height: 12),
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
                child: hasMedia
                    ? Image.network(
                        widget.publication.photo!,
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
          ],

          const SizedBox(height: 16),

          // ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Icône commentaires avec nombre
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicationDetailScreen(
                          publications: [widget.publication],
                          initialIndex: 0,
                        ),
                      ),
                    );
                  },
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
                          '${widget.publication.commentaires.length}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

        ],
      ),
    );
  }

  ImageProvider? _buildAuthorProfileImage() {
    final imageUrl = _buildImageUrl(widget.publication.auteurPhotoProfil);
    
    if (imageUrl.isNotEmpty) {
      print("🖼️ PublicationCard: Photo de profil de l'auteur: $imageUrl");
      return NetworkImage(imageUrl);
    }
    print("🖼️ PublicationCard: Aucune photo de profil pour l'auteur");
    return null;
  }

  Widget? _buildAuthorProfileFallback() {
    // Afficher une icône seulement si aucune photo n'est disponible
    if (widget.publication.auteurPhotoProfil == null || widget.publication.auteurPhotoProfil!.isEmpty) {
      return Icon(
        Icons.person,
        color: AppTheme.primaryColor,
        size: 20,
      );
    }
    return null;
  }
}
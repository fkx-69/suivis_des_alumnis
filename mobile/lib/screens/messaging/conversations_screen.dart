import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:memoire/models/conversation_model.dart';
import 'package:memoire/services/messaging_service.dart';
import 'package:memoire/screens/messaging/chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> with TickerProviderStateMixin {
  final MessagingService _messagingService = MessagingService();
  late Future<List<ConversationModel>> _conversationsFuture;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // Définir la locale française pour l'affichage des dates relatives
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _loadConversations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _conversationsFuture = _messagingService.fetchConversations();
    });
    _fadeController.forward();
  }

  void _navigateToChat(String username) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(peerUsername: username),
      ),
    ).then((_) {
      // Rafraîchir la liste des conversations au retour de l'écran de chat
      _loadConversations();
    });
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
        title: Text(
          'Conversations',
          style: textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _loadConversations,
          color: colorScheme.secondary,
          child: FutureBuilder<List<ConversationModel>>(
            future: _conversationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chargement des conversations...',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.subTextColor,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (snapshot.hasError) {
                return Container(
                  margin: const EdgeInsets.all(32),
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
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.errorColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erreur de chargement',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppTheme.subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.subTextColor.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              final conversations = snapshot.data;
              if (conversations == null || conversations.isEmpty) {
                return Container(
                  margin: const EdgeInsets.all(32),
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
                        Icons.chat_outlined,
                        size: 64,
                        color: AppTheme.subTextColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune conversation',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppTheme.subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Commencez une conversation pour discuter avec d\'autres membres',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.subTextColor.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: conversations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final convo = conversations[index];
                  // Utilisation de NetworkImage pour l'avatar, avec un fallback
                  final avatarImage = convo.photoProfil != null && convo.photoProfil!.isNotEmpty
                      ? NetworkImage(convo.photoProfil!)
                      : null;

                  return Container(
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _navigateToChat(convo.username),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Avatar
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 28,
                                  backgroundImage: avatarImage,
                                  backgroundColor: AppTheme.surfaceColor,
                                  child: (avatarImage == null)
                                      ? Text(
                                          convo.fullName.isNotEmpty ? convo.fullName[0].toUpperCase() : '?',
                                          style: textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Contenu
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            convo.fullName,
                                            style: textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          timeago.format(convo.dateLastMessage, locale: 'fr'),
                                          style: textTheme.bodySmall?.copyWith(
                                            color: AppTheme.subTextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      convo.lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: AppTheme.subTextColor.withOpacity(0.8),
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Badge de messages non lus
                              if (convo.unreadCount > 0) ...[
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    convo.unreadCount.toString(),
                                    style: textTheme.labelSmall?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

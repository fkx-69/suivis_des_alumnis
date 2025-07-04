import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/models/conversation_model.dart';
import 'package:memoire/services/messaging_service.dart';
import 'package:memoire/screens/group/chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({Key? key}) : super(key: key);

  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final MessagingService _messagingService = MessagingService();
  late Future<List<ConversationModel>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    // Définir la locale française pour l'affichage des dates relatives
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _conversationsFuture = _messagingService.fetchConversations();
    });
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations', style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadConversations,
        child: FutureBuilder<List<ConversationModel>>(
          future: _conversationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            }
            final conversations = snapshot.data;
            if (conversations == null || conversations.isEmpty) {
              return const Center(
                child: Text('Aucune conversation pour le moment.', style: TextStyle(fontSize: 16)),
              );
            }
            return ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
              itemBuilder: (context, index) {
                final convo = conversations[index];
                return ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.person, color: Colors.grey, size: 30),
                  ),
                  title: Text(convo.withUsername, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    convo.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(timeago.format(convo.dateLastMessage, locale: 'fr'), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      if (convo.unreadCount > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: CircleAvatar(
                            radius: 10,
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              convo.unreadCount.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () => _navigateToChat(convo.withUsername),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

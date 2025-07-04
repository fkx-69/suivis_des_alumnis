import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memoire/models/conversation_model.dart';
import 'package:memoire/screens/group/chat_screen.dart';
import 'package:memoire/services/messaging_service.dart';

class DiscussionsListScreen extends StatefulWidget {
  const DiscussionsListScreen({super.key});

  @override
  State<DiscussionsListScreen> createState() => _DiscussionsListScreenState();
}

class _DiscussionsListScreenState extends State<DiscussionsListScreen> {
  final MessagingService _messagingService = MessagingService();
  late Future<List<ConversationModel>> _conversationsFuture;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  void _loadConversations() {
    setState(() {
      _conversationsFuture = _messagingService.fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ConversationModel>>(
      future: _conversationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Erreur: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadConversations,
                  child: const Text('Réessayer'),
                )
              ],
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Aucune conversation.'));
        }

        final conversations = snapshot.data!;

        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            final hasUnread = conversation.unreadCount > 0;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, color: Colors.white),
                radius: 28,
              ),
              title: Text(
                conversation.withUsername,
                style: GoogleFonts.poppins(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                ),
              ),
              subtitle: Text(
                conversation.lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: hasUnread ? Colors.black : Colors.grey.shade600,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('HH:mm').format(conversation.dateLastMessage),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: hasUnread ? Colors.blue : Colors.grey,
                    ),
                  ),
                  if (hasUnread) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${conversation.unreadCount}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(peerUsername: conversation.withUsername),
                  ),
                ).then((_) => _loadConversations());
              },
            );
          },
        );
      },
    );
  }
}

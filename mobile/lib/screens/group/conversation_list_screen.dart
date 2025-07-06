import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memoire/models/conversation_model.dart';
import 'package:memoire/services/messaging_service.dart';
import 'package:memoire/screens/messaging/chat_screen.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({Key? key}) : super(key: key);
  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  final MessagingService _svc = MessagingService();
  bool _loading = true;
  String? _error;
  List<ConversationModel> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _conversations = await _svc.fetchConversations();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadConversations,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text('Erreur : $_error'))
            : ListView.separated(
          itemCount: _conversations.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final c = _conversations[i];
            final time = DateFormat.Hm().format(c.dateLastMessage);

            // Utilisation de NetworkImage pour l'avatar, avec un fallback
            final avatarImage = c.photoProfil != null && c.photoProfil!.isNotEmpty
                ? NetworkImage(c.photoProfil!)
                : null;

            return ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundImage: avatarImage,
                backgroundColor: Colors.grey[200],
                child: (avatarImage == null)
                    ? Text(
                        c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(fontSize: 24, color: Colors.grey[600]),
                      )
                    : null,
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    peerUsername: c.username, // CORRIGÉ
                  ),
                ),
              ),
              title: Text(c.fullName, // CORRIGÉ
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text(c.lastMessage,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(time,
                      style: GoogleFonts.poppins(fontSize: 12)),
                  if (c.unreadCount > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${c.unreadCount}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

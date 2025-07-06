import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memoire/models/private_message_model.dart';
import 'package:memoire/services/messaging_service.dart';
import 'package:memoire/services/auth_service.dart';

class ChatScreen extends StatefulWidget {
  final String peerUsername;
  const ChatScreen({Key? key, required this.peerUsername}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final MessagingService _svc = MessagingService();
  final AuthService      _auth = AuthService();

  List<PrivateMessageModel> _msgs = [];
  bool _loading = true;
  String? _error;
  String? _me;
  final _ctl = TextEditingController();
  Timer? _polling;

  @override
  void initState() {
    super.initState();
    _auth.getUserInfo().then((u) => setState(() => _me = u.username));
    _loadChat();
    _polling = Timer.periodic(const Duration(seconds: 5), (_) => _loadChat());
  }

  @override
  void dispose() {
    _polling?.cancel();
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _loadChat() async {
    // Set loading state and clear previous errors only on initial load.
    if (_msgs.isEmpty) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final messages = await _svc.fetchWith(widget.peerUsername);
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      if (mounted) {
        setState(() {
          _msgs = messages;
          _error = null; // Clear error on success
        });
      }
    } catch (e) {
      if (mounted) {
        // On initial load, display the error. On subsequent polling errors,
        // we can choose to keep the old messages and not show an error to avoid flickering.
        if (_msgs.isEmpty) {
          setState(() {
            _error = e.toString();
          });
        }
      }
    } finally {
      if (mounted && _loading) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _send() async {
    final txt = _ctl.text.trim();
    if (txt.isEmpty) return;
    _ctl.clear();
    try {
      await _svc.sendMessage(toUsername: widget.peerUsername, contenu: txt);
    } catch (e) {
      // Optionally handle send errors, e.g., show a snackbar.
    }
    _loadChat(); // Refresh chat after sending.
  }

  // Helper to check if two dates are on the same day.
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Formats the date for the separator with localization.
  String _formatDateSeparator(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCompare = DateTime(date.year, date.month, date.day);

    if (dateToCompare == today) {
      return 'Aujourd\'hui';
    } else if (dateToCompare == yesterday) {
      return 'Hier';
    } else {
      return DateFormat.yMMMMd('fr').format(date);
    }
  }

  // Builds the date separator widget.
  Widget _buildDateSeparator(DateTime date) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _formatDateSeparator(context, date),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // Builds a single message bubble.
  Widget _buildMessageItem(PrivateMessageModel m) {
    final mine = (m.expediteur.username == _me);
    final time = DateFormat.Hm().format(m.timestamp);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .7,
        ),
        decoration: BoxDecoration(
          color: mine ? Theme.of(context).primaryColor.withOpacity(0.9) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(m.contenu, style: GoogleFonts.poppins(color: mine ? Colors.white : Colors.black87)),
            const SizedBox(height: 4),
            Text(
              time,
              style: GoogleFonts.poppins(fontSize: 11, color: mine ? Colors.white70 : Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerUsername, style: GoogleFonts.poppins()),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Erreur de chargement des messages.\nVeuillez réessayer.\n\nDétail: $_error',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(color: Colors.red),
                          ),
                        ),
                      )
                    : _msgs.isEmpty
                        ? Center(
                            child: Text(
                              'Aucun message dans cette conversation.\nSoyez le premier à en envoyer un !',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            reverse: true, // Key for modern chat UI
                            padding: const EdgeInsets.all(12),
                            itemCount: _msgs.length,
                            itemBuilder: (_, i) {
                              final index = _msgs.length - 1 - i;
                              final m = _msgs[index];

                              final bool isFirstMessageOfDay = (index == 0) || !_isSameDay(_msgs[index - 1].timestamp, m.timestamp);

                              if (isFirstMessageOfDay) {
                                return Column(
                                  children: [
                                    _buildDateSeparator(m.timestamp),
                                    _buildMessageItem(m),
                                  ],
                                );
                              } else {
                                return _buildMessageItem(m);
                              }
                            },
                          ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(top: BorderSide(color: Colors.grey.shade300))),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctl,
                      decoration: InputDecoration(
                        hintText: 'Écrire un message…',
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

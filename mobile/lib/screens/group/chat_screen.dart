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
    setState(() => _loading = true);
    try {
      _msgs = await _svc.fetchWith(widget.peerUsername);
    } catch (_) {
      _msgs = [];
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final txt = _ctl.text.trim();
    if (txt.isEmpty) return;
    await _svc.sendMessage(toUsername: widget.peerUsername, contenu: txt);
    _ctl.clear();
    _loadChat();
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
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _msgs.length,
              itemBuilder: (_, i) {
                final m = _msgs[i];
                final mine = (m.expediteur.username == _me);
                final time = DateFormat.Hm().format(m.timestamp);
                return Align(
                  alignment:
                  mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .7),
                    decoration: BoxDecoration(
                      color: mine
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: mine
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(m.contenu, style: GoogleFonts.poppins()),
                        const SizedBox(height: 4),
                        Text(time,
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey.shade300))),
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
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF2196F3)),
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

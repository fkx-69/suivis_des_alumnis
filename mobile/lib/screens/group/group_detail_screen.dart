// lib/screens/group/group_detail_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memoire/models/group_model.dart';
import 'package:memoire/services/group_service.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/screens/group/group_member_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final GroupeService _svc = GroupeService();
  final AuthService   _auth = AuthService();

  List<GroupMessageModel> _msgs        = [];
  bool                    _loadingMsgs = false;
  bool                    _isMember    = false;
  String?                 _meUsername;
  final _msgCtl = TextEditingController();
  Timer? _polling;

  @override
  void initState() {
    super.initState();
    _isMember = widget.group.isMember;
    _auth.getUserInfo().then((u) {
      setState(() => _meUsername = u.username);
    });
    if (_isMember) _startChat();
  }

  void _startChat() {
    _loadMessages();
    _polling ??= Timer.periodic(const Duration(seconds: 5), (_) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _polling?.cancel();
    _msgCtl.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _loadingMsgs = true);
    try {
      _msgs = await _svc.fetchMessages(widget.group.id);
    } catch (_) {
      _msgs = [];
    } finally {
      setState(() => _loadingMsgs = false);
    }
  }

  Future<void> _join() async {
    await _svc.joinGroup(widget.group.id);
    setState(() => _isMember = true);
    _startChat();
  }

  Future<void> _send() async {
    final text = _msgCtl.text.trim();
    if (text.isEmpty) return;

    setState(() => _loadingMsgs = true);
    try {
      await _svc.sendMessage(id: widget.group.id, contenu: text);
      _msgCtl.clear();
      _msgs = await _svc.fetchMessages(widget.group.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec envoi : $e')),
      );
    } finally {
      setState(() => _loadingMsgs = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.nomGroupe, style: GoogleFonts.poppins()),
        actions: [
          if (_isMember)
            IconButton(
              icon: const Icon(Icons.group),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GroupMembersScreen(
                    groupId: widget.group.id,
                    groupName: widget.group.nomGroupe,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // description & bouton rejoindre
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.group.description,
                    style: GoogleFonts.poppins(color: Colors.grey[800])),
                const SizedBox(height: 12),
                if (!_isMember)
                  Center(
                    child: ElevatedButton(
                      onPressed: _join,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text('Rejoindre le groupe',
                          style: GoogleFonts.poppins(color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),

          // chat
          Expanded(
            child: _loadingMsgs
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              itemCount: _msgs.length,
              itemBuilder: (ctx, i) {
                final m = _msgs[i];
                final mine = (m.auteurUsername == _meUsername);
                final time = DateFormat.Hm().format(m.dateEnvoi);

                final bool showDateHeader = i == 0 ||
                    _msgs[i].dateEnvoi.day != _msgs[i - 1].dateEnvoi.day ||
                    _msgs[i].dateEnvoi.month != _msgs[i - 1].dateEnvoi.month ||
                    _msgs[i].dateEnvoi.year != _msgs[i - 1].dateEnvoi.year;

                final messageBubble = Align(
                  alignment:
                      mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * .7),
                    decoration: BoxDecoration(
                      color: mine
                          ? Colors.green.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(m.auteurUsername,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(m.message, style: GoogleFonts.poppins()),
                        const SizedBox(height: 4),
                        Text(time,
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                );

                if (showDateHeader) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          DateFormat.yMMMMd('fr').format(m.dateEnvoi),
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                      messageBubble,
                    ],
                  );
                } else {
                  return messageBubble;
                }
              },
            ),
          ),

          // input & send (uniquement si membre)
          if (_isMember)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border:
                  Border(top: BorderSide(color: Colors.grey.shade300))),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgCtl,
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

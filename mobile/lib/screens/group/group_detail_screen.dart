// lib/screens/group/group_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memoire/models/group_model.dart';
import 'package:memoire/services/group_service.dart';

class GroupDetailScreen extends StatefulWidget {
  final GroupModel group;
  const GroupDetailScreen({super.key, required this.group});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final _svc = GroupeService();
  final _msgCtl = TextEditingController();
  List<GroupMessageModel> _msgs = [];
  bool _loading = true;
  bool _isMember = false;

  @override
  void initState() {
    super.initState();
    _checkMembershipAndLoad();
  }

  Future<void> _checkMembershipAndLoad() async {
    // assume that si premier fetchMessages 403 = pas membre
    try {
      _msgs = await _svc.fetchMessages(widget.group.id);
      _isMember = true;
    } catch (e) {
      _isMember = false;
    }
    setState(() => _loading = false);
  }

  Future<void> _join() async {
    await _svc.joinGroup(widget.group.id);
    setState(() => _loading = true);
    await _checkMembershipAndLoad();
  }

  Future<void> _send() async {
    final txt = _msgCtl.text.trim();
    if (txt.isEmpty) return;
    await _svc.sendMessage(id: widget.group.id, contenu: txt);
    _msgCtl.clear();
    _msgs = await _svc.fetchMessages(widget.group.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // header
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 48, bottom: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(widget.group.nomGroupe,
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      const Spacer(flex: 2),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(widget.group.description,
                        style: GoogleFonts.poppins(color: Colors.white70)),
                  ),
                  if (!_loading && !_isMember)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: ElevatedButton(
                        onPressed: _join,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Color(0xFF2196F3),
                        ),
                        child: const Text('Rejoindre'),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // messages / joining
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (!_isMember)
            Expanded(
              child: Center(
                child: Text(
                  'Vous devez rejoindre le groupe pour lire les messages',
                  style: GoogleFonts.poppins(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _msgs.length,
                itemBuilder: (ctx, i) {
                  final m = _msgs[i];
                  final isMine = m.auteurUsername.toLowerCase() == 'vous';
                  final time = DateFormat.Hm().format(m.dateEnvoi);
                  return Align(
                    alignment:
                    isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * .7),
                      decoration: BoxDecoration(
                        color: isMine
                            ? const Color(0xFF4CAF50).withOpacity(.1)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: isMine
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
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
                },
              ),
            ),

          // input
          if (!_loading && _isMember)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade300))),
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

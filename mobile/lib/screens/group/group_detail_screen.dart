// lib/screens/group/group_detail_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
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

class _GroupDetailScreenState extends State<GroupDetailScreen> with TickerProviderStateMixin {
  final GroupeService _svc = GroupeService();
  final AuthService   _auth = AuthService();

  List<GroupMessageModel> _msgs        = [];
  bool                    _loadingMsgs = false;
  bool                    _isMember    = false;
  String?                 _meUsername;
  final _msgCtl = TextEditingController();
  Timer? _polling;

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

    _isMember = widget.group.isMember;
    _auth.getUserInfo().then((u) {
      setState(() => _meUsername = u.username);
    });
    if (_isMember) _startChat();
    _fadeController.forward();
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
    _fadeController.dispose();
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
        SnackBar(
          backgroundColor: AppTheme.errorColor,
          content: Text(
            'Échec envoi : $e',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } finally {
      setState(() => _loadingMsgs = false);
    }
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.group.nomGroupe,
          style: textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_isMember) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.group,
                  color: colorScheme.secondary,
                  size: 24,
                ),
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
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'quit') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Quitter le groupe'),
                      content: const Text('Es-tu sûr de vouloir quitter ce groupe ?'),
                      actions: [
                        TextButton(
                          child: const Text('Annuler'),
                          onPressed: () => Navigator.of(ctx).pop(false),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Oui, quitter'),
                          onPressed: () => Navigator.of(ctx).pop(true),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await _svc.quitGroup(widget.group.id);
                    if (mounted) {
                      Navigator.of(context).pop(true); // pour signaler à la page précédente qu’on doit rafraîchir

                    }
                  }
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: 'quit',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Quitter le groupe', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],

        surfaceTintColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Description & bouton rejoindre
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.secondary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.group.description,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isMember)
                    Center(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _join,
                          icon: Icon(
                            Icons.group_add,
                            color: Colors.black,
                            size: 20,
                          ),
                          label: Text(
                            'Rejoindre le groupe',
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Chat
            Expanded(
              child: _loadingMsgs
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chargement des messages...',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.subTextColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _msgs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_outlined,
                                size: 64,
                                color: AppTheme.subTextColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun message',
                                style: textTheme.titleMedium?.copyWith(
                                  color: AppTheme.subTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Soyez le premier à envoyer un message !',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.subTextColor.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(16),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * .7,
                                ),
                                decoration: BoxDecoration(
                                  color: mine
                                      ? colorScheme.secondary
                                      : AppTheme.surfaceColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: mine
                                        ? Colors.transparent
                                        : AppTheme.borderColor,
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      m.auteurUsername,
                                      style: textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: mine ? Colors.black : AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      m.message,
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: mine ? Colors.black : AppTheme.primaryColor,
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      time,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: mine
                                            ? Colors.black.withOpacity(0.6)
                                            : AppTheme.subTextColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            if (showDateHeader) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceColor,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppTheme.borderColor,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        DateFormat.yMMMMd('fr').format(m.dateEnvoi),
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppTheme.subTextColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
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

            // Input & send (uniquement si membre)
            if (_isMember)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  border: Border(
                    top: BorderSide(color: AppTheme.borderColor),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppTheme.borderColor,
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _msgCtl,
                          decoration: InputDecoration(
                            hintText: 'Écrire un message…',
                            hintStyle: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.subTextColor.withOpacity(0.7),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: InputBorder.none,
                          ),
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.black,
                          size: 20,
                        ),
                        onPressed: _send,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

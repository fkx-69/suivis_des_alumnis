import 'dart:async';
import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
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

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final MessagingService _svc = MessagingService();
  final AuthService      _auth = AuthService();

  List<PrivateMessageModel> _msgs = [];
  bool _loading = true;
  String? _error;
  String? _me;
  final _ctl = TextEditingController();
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
    
    _auth.getUserInfo().then((u) => setState(() => _me = u.username));
    _loadChat();
    _polling = Timer.periodic(const Duration(seconds: 5), (_) => _loadChat());
    _fadeController.forward();
  }

  @override
  void dispose() {
    _polling?.cancel();
    _ctl.dispose();
    _fadeController.dispose();
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
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
          _formatDateSeparator(context, date),
          style: textTheme.bodySmall?.copyWith(
            color: AppTheme.subTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Builds a single message bubble.
  Widget _buildMessageItem(PrivateMessageModel m) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final mine = (m.expediteur.username == _me);
    final time = DateFormat.Hm().format(m.timestamp);
    
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * .7,
        ),
        decoration: BoxDecoration(
          color: mine ? colorScheme.secondary : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mine ? Colors.transparent : AppTheme.borderColor,
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
              m.contenu,
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
          widget.peerUsername,
          style: textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        surfaceTintColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Expanded(
              child: _loading
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
                  : _error != null
                      ? Container(
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
                                'Veuillez réessayer.\n\nDétail: $_error',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.subTextColor.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
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
                              reverse: true, // Key for modern chat UI
                              padding: const EdgeInsets.symmetric(vertical: 8),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                border: Border(
                  top: BorderSide(color: AppTheme.borderColor),
                ),
              ),
              child: SafeArea(
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
                          controller: _ctl,
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
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.black,
                          size: 18,
                        ),
                        onPressed: _send,
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

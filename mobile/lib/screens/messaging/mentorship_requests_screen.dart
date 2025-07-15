import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:memoire/models/mentorship_request_model.dart';
import 'package:memoire/models/user_model.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/services/messaging_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class MentorshipRequestsScreen extends StatefulWidget {
  const MentorshipRequestsScreen({super.key});

  @override
  State<MentorshipRequestsScreen> createState() => _MentorshipRequestsScreenState();
}

class _MentorshipRequestsScreenState extends State<MentorshipRequestsScreen> with TickerProviderStateMixin {
  final MessagingService _messagingService = MessagingService();
  final AuthService _authService = AuthService();
  late Future<List<MentorshipRequestModel>> _requestsFuture;
  int? _currentUserId;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _loadRequests();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Recharge les données et rafraîchit l'interface
  void _loadRequests() {
    setState(() {
      _currentUserId = _authService.currentUser?.id;
      _requestsFuture = _messagingService.fetchMyMentorshipRequests();
    });
    _fadeController.forward();
  }

  Future<void> _handleResponse(MentorshipRequestModel request, String status) async {
    // Capturez les dépendances du BuildContext avant les opérations asynchrones.
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    String? reason;
    if (status == 'refusee') {
      reason = await showDialog<String>(
        context: context,
        builder: (context) => _ReasonDialog(),
      );
      if (reason == null) return; // User cancelled
    }

    if (!mounted) return;

    try {
      await _messagingService.respondToMentorshipRequest(
        requestId: request.id,
        status: status,
        reason: reason,
      );
      scaffoldMessenger.showSnackBar(
        SnackBar(
          backgroundColor: status == 'acceptee' ? AppTheme.successColor : AppTheme.errorColor,
          content: Text(
            'Demande ${status == 'acceptee' ? 'acceptée' : 'refusée'}',
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
      _loadRequests();
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.errorColor,
            content: Text(
              'Erreur : $e',
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
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (_currentUserId == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Container(
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Impossible de charger votre profil.',
                  style: textTheme.titleMedium?.copyWith(
                    color: AppTheme.subTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadRequests,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Réessayer',
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
          'Demandes de mentorat',
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
          onRefresh: () async => _loadRequests(),
          color: colorScheme.secondary,
          child: FutureBuilder<List<MentorshipRequestModel>>(
            future: _requestsFuture,
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
                        'Chargement des demandes...',
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
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                        Icons.people_outline,
                        size: 64,
                        color: AppTheme.subTextColor.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune demande de mentorat',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppTheme.subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Vous n\'avez pas encore reçu de demandes de mentorat',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.subTextColor.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final requests = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: requests.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final request = requests[index];
                  final bool isSender = request.etudiant.id == _currentUserId;
                  final UserModel user = isSender ? request.mentor : request.etudiant;
                  
                  return _MentorshipRequestCard(
                    request: request,
                    user: user,
                    isSender: isSender,
                    onAccept: () => _handleResponse(request, 'acceptee'),
                    onRefuse: () => _handleResponse(request, 'refusee'),
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

class _MentorshipRequestCard extends StatelessWidget {
  final MentorshipRequestModel request;
  final UserModel user;
  final bool isSender;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  const _MentorshipRequestCard({
    required this.request,
    required this.user,
    required this.isSender,
    required this.onAccept,
    required this.onRefuse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    
    final isPending = request.statut.toLowerCase() == 'en_attente';
    final isAccepted = request.statut.toLowerCase() == 'acceptee';
    final isRefused = request.statut.toLowerCase() == 'refusee';
    
    Color statusColor;
    Color cardColor;
    IconData statusIcon;
    
    if (isPending) {
      statusColor = colorScheme.secondary;
      cardColor = colorScheme.secondary.withOpacity(0.1);
      statusIcon = Icons.schedule;
    } else if (isAccepted) {
      statusColor = AppTheme.successColor;
      cardColor = AppTheme.successColor.withOpacity(0.1);
      statusIcon = Icons.check_circle;
    } else {
      statusColor = AppTheme.errorColor;
      cardColor = AppTheme.errorColor.withOpacity(0.1);
      statusIcon = Icons.cancel;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isSender ? 'À' : 'De'}: @${user.username}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(request.dateDemande, locale: 'fr'),
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTheme.subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (request.message != null && request.message!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Text(
                  request.message!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Statut: ',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppTheme.subTextColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.statut,
                    style: textTheme.labelMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (isPending && !isSender) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text(
                          'Accepter',
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: onRefuse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text(
                          'Refuser',
                          style: textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReasonDialog extends StatefulWidget {
  @override
  _ReasonDialogState createState() => _ReasonDialogState();
}

class _ReasonDialogState extends State<_ReasonDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      backgroundColor: AppTheme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Raison du refus',
        style: textTheme.titleMedium?.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: TextField(
        controller: _reasonController,
        decoration: InputDecoration(
          hintText: 'Expliquez pourquoi vous refusez cette demande...',
          hintStyle: textTheme.bodyMedium?.copyWith(
            color: AppTheme.subTextColor.withOpacity(0.7),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.secondary, width: 2),
          ),
          filled: true,
          fillColor: AppTheme.surfaceColor,
        ),
        style: textTheme.bodyMedium?.copyWith(
          color: AppTheme.primaryColor,
        ),
        maxLines: 3,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Annuler',
            style: textTheme.labelLarge?.copyWith(
              color: AppTheme.subTextColor,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_reasonController.text),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.errorColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Refuser',
            style: textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

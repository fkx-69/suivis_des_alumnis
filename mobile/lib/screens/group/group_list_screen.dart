import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:memoire/models/group_model.dart';
import 'package:memoire/services/group_service.dart';
import 'package:memoire/widgets/group/group_circle.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({Key? key}) : super(key: key);
  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> with TickerProviderStateMixin {
  final GroupeService _svc = GroupeService();
  bool _loading = true;
  String? _error;
  List<GroupModel> _allGroups = [];

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
    _loadGroups();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadGroups() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _allGroups = await _svc.fetchGroups();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _loading = false);
      _fadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _loadGroups,
          color: colorScheme.secondary,
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
                        'Chargement des groupes...',
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
                            _error!,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppTheme.subTextColor.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _loadGroups,
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.black,
                              size: 20,
                            ),
                            label: Text(
                              'Réessayer',
                              style: textTheme.labelLarge?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildContent(),
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: Icon(
            Icons.group_add,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () async {
            final created = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
            );
            if (created == true) _loadGroups();
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    
    final horizontaux = _allGroups;
    final verticaux = _allGroups.where((g) => g.isMember).toList();

    // Calcul responsive pour la hauteur
    final isSmallScreen = size.width < 400;
    final sectionHeight = isSmallScreen ? 140.0 : 120.0;
    final horizontalPadding = size.width * 0.04;
    final itemSpacing = size.width * 0.02;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section groupes horizontaux
          Container(
            height: sectionHeight,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tous les groupes',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: horizontaux.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_outlined,
                                size: 32,
                                color: AppTheme.subTextColor.withOpacity(0.5),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Aucun groupe disponible',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.subTextColor.withOpacity(0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: itemSpacing),
                          itemCount: horizontaux.length,
                          itemBuilder: (_, i) {
                            final g = horizontaux[i];
                            return Padding(
                              padding: EdgeInsets.only(right: itemSpacing),
                              child: GroupCircle(
                                nom: g.nomGroupe,
                                isMember: g.isMember,
                                onTap: g.isMember
                                    ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => GroupDetailScreen(group: g),
                                      ),
                                    ).then((r) {
                                      if (r == true) _loadGroups();
                                    })
                                    : null,
                                onJoin: g.isMember
                                    ? null
                                    : () async {
                                      await _svc.joinGroup(g.id);
                                      await _loadGroups();
                                    },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Séparateur
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: AppTheme.borderColor,
          ),

          // Section mes groupes
          Padding(
            padding: EdgeInsets.all(horizontalPadding),
            child: Text(
              'Mes groupes',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
          verticaux.isEmpty
              ? Container(
                  margin: EdgeInsets.all(horizontalPadding * 2),
                  padding: EdgeInsets.all(horizontalPadding * 2),
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
                        Icons.group_outlined,
                        size: isSmallScreen ? 48 : 64,
                        color: AppTheme.subTextColor.withOpacity(0.5),
                      ),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      Text(
                        'Aucun groupe rejoint',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppTheme.subTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rejoignez des groupes pour commencer à discuter',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.subTextColor.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
              shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 8),
                  itemCount: verticaux.length,
                  itemBuilder: (_, i) {
                    final g = verticaux[i];
                    return Container(
                      margin: EdgeInsets.only(bottom: itemSpacing * 2),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(builder: (_) => GroupDetailScreen(group: g)),
                            );
                            if (result == true) _loadGroups();
                          },

                          child: Padding(
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    radius: isSmallScreen ? 20 : 24,
                                    backgroundColor: AppTheme.surfaceColor,
                                    backgroundImage: (g.photoProfil != null && g.photoProfil!.isNotEmpty)
                                        ? NetworkImage(g.photoProfil!)
                                        : null,
                                    child: (g.photoProfil == null || g.photoProfil!.isEmpty)
                                        ? Text(
                                      g.nomGroupe[0].toUpperCase(),
                                      style: textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                        fontSize: isSmallScreen ? 16 : null,
                                      ),
                                    )
                                        : null,
                                  ),
                                ),

                                SizedBox(width: isSmallScreen ? 12 : 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        g.nomGroupe,
                                        style: textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        g.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.subTextColor.withOpacity(0.8),
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppTheme.subTextColor.withOpacity(0.5),
                                  size: isSmallScreen ? 18 : 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}

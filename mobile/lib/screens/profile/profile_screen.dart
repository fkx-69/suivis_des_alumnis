import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import '../../models/user_model.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/services/parcours_service.dart';
import 'package:memoire/widgets/profile_widgets/profile_header.dart';
import 'package:memoire/widgets/profile_widgets/user_info_card.dart';
import 'package:memoire/widgets/profile_widgets/user_publication_list.dart';
import 'package:memoire/screens/profile/edit_parcours_screen.dart';
import 'package:memoire/widgets/profile_widgets/parcours_display_section.dart';
import 'create_publication_screen.dart';
import 'package:memoire/screens/profile/settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final ParcoursService _parcoursSvc = ParcoursService();

  UserModel? _user;
  List<Map<String, dynamic>> _parcoursA = [];
  List<Map<String, dynamic>> _parcoursP = [];
  bool _isLoading = true;

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
    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await _authService.getUserInfo();
    final isAlumni = user.role.toUpperCase() == 'ALUMNI';

    // charger parcours
    List<Map<String, dynamic>> acad = [], prof = [];
    if (isAlumni) {
      acad = await _parcoursSvc.getParcoursAcademiques();
      prof = await _parcoursSvc.getParcoursProfessionnels();
    }

    setState(() {
      _user = user;
      _parcoursA = acad;
      _parcoursP = prof;
      _isLoading = false;
    });
    
    _fadeController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    if (_isLoading || _user == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
              ),
              const SizedBox(height: 16),
              Text(
                'Chargement du profil...',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppTheme.subTextColor,
                ),
              ),
            ],
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
        automaticallyImplyLeading: false,
        title: Text(
          'Mon Profil',
          style: textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: colorScheme.secondary,
              size: 24,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
        surfaceTintColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _loadData,
          color: colorScheme.secondary,
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // En-tête profil
              ProfileHeader(
                user: _user!,
                onProfileUpdated: _loadData,
              ),
              const SizedBox(height: 20),

              // Infos utilisateur
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: UserInfoCard(user: _user!),
              ),
              const SizedBox(height: 24),

              // Parcours (alumni uniquement)
              if (_user!.role.toUpperCase() == 'ALUMNI') ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      ModernSectionTitle(
                        icon: Icons.timeline,
                        title: 'Mon Parcours',
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditParcoursScreen()),
                        ),
                        icon: Icon(
                          Icons.edit,
                          size: 14,
                          color: colorScheme.secondary,
                        ),
                        label: Text(
                          'Modifier',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (_parcoursA.isEmpty && _parcoursP.isEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.timeline_outlined,
                          size: 48,
                          color: AppTheme.subTextColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun parcours à afficher',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.subTextColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ajoutez votre parcours pour le partager avec la communauté',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppTheme.subTextColor.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else ...[
                  // Section parcours académiques
                  ParcoursDisplaySection(
                    title: 'Parcours Académiques',
                    icon: Icons.school,
                    items: _parcoursA,
                    titleField: 'diplome',
                    subtitleFields: ['institution', 'annee_obtention', 'mention'],
                  ),
                  // Section parcours professionnels
                  ParcoursDisplaySection(
                    title: 'Parcours Professionnels',
                    icon: Icons.work,
                    items: _parcoursP,
                    titleField: 'poste',
                    subtitleFields: ['entreprise', 'date_debut', 'type_contrat'],
                  ),
                ],
                const SizedBox(height: 32),
              ],

              // Publications récentes
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ModernSectionTitle(
                  icon: Icons.article_outlined,
                  title: 'Publications récentes',
                ),
              ),
              const SizedBox(height: 16),
              UserPublicationsList(username: _user!.username),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePublicationScreen()),
          ).then((_) => _loadData());
        },
        backgroundColor: colorScheme.secondary,
        foregroundColor: Colors.black,
        elevation: 4,
        child: const Icon(Icons.add, size: 24),
        tooltip: 'Créer une publication',
      ),
    );
  }
}

class ModernSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  
  const ModernSectionTitle({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.secondary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }
}

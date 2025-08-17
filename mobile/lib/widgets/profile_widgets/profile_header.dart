import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import '../../../models/user_model.dart';
import 'package:memoire/screens/profile/edit_profile_screen.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onProfileUpdated;
  
  const ProfileHeader({
    super.key, 
    required this.user,
    this.onProfileUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: AppTheme.accentGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withAlpha(76), // ~0.3 opacity
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: _buildProfileImage(user, textTheme),
                ),

              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${user.prenom} ${user.nom}',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.alternate_email,
                          size: 16,
                          color: Colors.white.withAlpha(200),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '@${user.username}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withAlpha(230),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (user.role.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(50),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (user.biographie != null && user.biographie!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withAlpha(50),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.format_quote,
                    color: Colors.white.withAlpha(180),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.biographie!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withAlpha(230),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
                // Si l'utilisateur a été mis à jour, on recharge les données
                if (result != null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profil mis à jour avec succès'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                    // Appeler le callback pour recharger les données
                    onProfileUpdated?.call();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              icon: Icon(
                Icons.edit,
                size: 18,
                color: AppTheme.primaryColor,
              ),
              label: Text(
                'Modifier le profil',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }
  Widget _buildProfileImage(UserModel user, TextTheme textTheme) {
    // Vérifier si l'utilisateur a une photo de profil
    if (user.photoProfil != null && user.photoProfil!.isNotEmpty) {
      print('🖼️ ProfileHeader: Affichage de la photo: ${user.photoProfil}');
      
      // Vérifier si c'est une URL valide
      if (user.photoProfil!.startsWith('http')) {
        return Image.network(
          user.photoProfil!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('❌ ProfileHeader: Erreur de chargement de l\'image: $error');
            return _buildFallbackInitials(user, textTheme);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 80,
              height: 80,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          },
        );
      } else {
        print('⚠️ ProfileHeader: URL de photo invalide: ${user.photoProfil}');
        return _buildFallbackInitials(user, textTheme);
      }
    }
    
    print('🖼️ ProfileHeader: Aucune photo, affichage des initiales');
    return _buildFallbackInitials(user, textTheme);
  }

  Widget _buildFallbackInitials(UserModel user, TextTheme textTheme) {
    return Container(
      width: 80,
      height: 80,
      color: AppTheme.surfaceColor,
      alignment: Alignment.center,
      child: Text(
        '${user.prenom[0]}${user.nom[0]}'.toUpperCase(),
        style: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

}

import 'package:flutter/material.dart';
import 'package:memoire/models/user_model.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:memoire/constants/api_constants.dart';
import 'package:memoire/screens/profile/public_profile_screen.dart';

class UserMiniCard extends StatelessWidget {
  final UserModel user;

  const UserMiniCard({Key? key, required this.user}) : super(key: key);

  String _buildImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      print("🔍 UserMiniCard: URL d'image vide ou null");
      return '';
    }
    
    print("🔍 UserMiniCard: URL originale: $imageUrl");
    
    // Si l'URL commence déjà par http, on la retourne telle quelle
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      print("🔍 UserMiniCard: URL complète détectée: $imageUrl");
      return imageUrl;
    }
    
    // Sinon, on construit l'URL complète avec le baseUrl
    // Utiliser l'URL du serveur local
    final baseUrl = "http://192.168.1.15:8000";
    final fullUrl = '$baseUrl$imageUrl';
    print("🔍 UserMiniCard: URL construite: $fullUrl");
    return fullUrl;
  }

  @override
  Widget build(BuildContext context) {
    // Debug pour voir les URLs des photos de profil
    print("🔍 UserMiniCard - Username: ${user.username}");
    print("🔍 UserMiniCard - Photo profil originale: ${user.photoProfil}");
    
    final imageUrl = _buildImageUrl(user.photoProfil);
    print("🔍 UserMiniCard - Photo profil construite: $imageUrl");
    
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppTheme.surfaceColor,
              child: imageUrl.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        imageUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        headers: {
                          'Accept': 'image/*',
                          'User-Agent': 'AlumniFy/1.0',
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print("❌ Erreur chargement image pour ${user.username}: $error");
                          print("❌ URL qui a échoué: $imageUrl");
                          return Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.person,
                                size: 24,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.jpeg',
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: 24,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              "@${user.username}",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PublicProfileScreen(username: user.username),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                backgroundColor: AppTheme.primaryColor,
                minimumSize: Size.zero,
              ),
              child: const Text(
                "Voir profil",
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

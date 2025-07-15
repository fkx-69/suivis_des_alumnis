import 'package:flutter/material.dart';
import 'package:memoire/models/user_model.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:memoire/screens/profile/public_profile_screen.dart';

class UserMiniCard extends StatelessWidget {
  final UserModel user;

  const UserMiniCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              backgroundImage: user.photoProfil != null
                  ? NetworkImage(user.photoProfil!)
                  : null,
              child: user.photoProfil == null
                  ? Text(user.prenom[0], style: const TextStyle(fontSize: 24))
                  : null,
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

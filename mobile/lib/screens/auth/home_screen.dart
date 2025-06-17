import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/widgets/auth_widgets/login_button.dart';
import 'package:memoire/widgets/auth_widgets/register_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                // Force la hauteur minimale à l'espace dispo
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    // Centre verticalement sans IntrinsicHeight
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icône ou logo
                      const Icon(
                        Icons.school,
                        size: 100,
                        color: Color(0xFF2196F3),
                      ),
                      const SizedBox(height: 24),

                      // Titre
                      Text(
                        'Bienvenue sur AlumniFy',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2196F3),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Sous-titre
                      Text(
                        'Connectez-vous avec les anciens étudiants\net partagez vos expériences',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Bouton Connexion (plein largeur)
                      SizedBox(
                        width: double.infinity,
                        child: LoginButton(),
                      ),
                      const SizedBox(height: 16),

                      // Bouton Inscription (plein largeur)
                      SizedBox(
                        width: double.infinity,
                        child: RegisterButton(),
                      ),

                      // Spacer virtuel : pousse vers le centre si écran plus grand
                      const SizedBox(height: 1),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

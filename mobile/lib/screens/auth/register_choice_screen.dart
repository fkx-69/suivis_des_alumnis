import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/screens/auth/register_student_screen.dart';
import 'package:memoire/screens/auth/register_alumni_screen.dart';
import 'package:memoire/widgets/auth_widgets/choice_card.dart';

class RegisterChoiceScreen extends StatelessWidget {
  const RegisterChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Créer un compte',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sélectionnez votre profil pour commencer',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 32),

              // Carte Étudiant
              ChoiceCard(
                title: 'Étudiant',
                description: 'Inscrivez-vous comme étudiant pour suivre votre parcours académique.',
                icon: Icons.school_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterEtudiantScreen()),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Carte Alumni
              ChoiceCard(
                title: 'Alumni',
                description: 'Inscrivez-vous comme alumni pour partager votre expérience professionnelle.',
                icon: Icons.person_outline,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterAlumniScreen()),
                  );
                },
              ),

              const Spacer(),

              // Bouton retour
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
                  label: Text(
                    'Retour',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF2196F3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

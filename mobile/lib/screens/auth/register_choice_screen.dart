import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_student_screen.dart';
import 'register_alumni_screen.dart';
import 'package:memoire/widgets/auth_widgets/choice_card.dart';

class RegisterChoiceScreen extends StatelessWidget {
  const RegisterChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/logo.png', height: 120),
              const SizedBox(height: 32),
              Text(
                'Choisissez votre profil',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(height: 32),
              ChoiceCard(
                title: 'Étudiant',
                description: 'Je suis actuellement étudiant et je cherche un mentor',
                icon: Icons.school_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterEtudiantScreen()),
                ),
              ),
              const SizedBox(height: 16),
              ChoiceCard(
                title: 'Alumni',
                description: 'Je suis diplômé et je souhaite partager mon expérience',
                icon: Icons.work_outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterAlumniScreen()),
                ),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Retour',
                  style: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFF2196F3)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

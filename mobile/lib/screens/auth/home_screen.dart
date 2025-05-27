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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 100, color: Color(0xFF2196F3)),
              const SizedBox(height: 24),
              Text(
                'Bienvenue sur AlumniFy',
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF2196F3)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Connectez-vous avec les anciens étudiants et partagez vos expériences',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              LoginButton(),
              const SizedBox(height: 16),
              RegisterButton(),
            ],
          ),
        ),
      ),
    );
  }
}

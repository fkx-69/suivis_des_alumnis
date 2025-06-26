import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/widgets/auth_widgets/register_student_form.dart';
import 'package:memoire/widgets/auth_widgets/login_link.dart'; // Assure-toi que ce fichier existe

class RegisterEtudiantScreen extends StatelessWidget {
  const RegisterEtudiantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Inscription Étudiant',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2196F3),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RegisterStudentForm(),
              const SizedBox(height: 16),
              LoginLink(
                onTap: () {
                  // TODO: Naviguer vers la page d'inscription
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

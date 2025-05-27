import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupLink extends StatelessWidget {
  final VoidCallback onTap;

  const SignupLink({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: GoogleFonts.poppins(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            'S\'inscrire',
            style: GoogleFonts.poppins(
              color: const Color(0xFF2196F3),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

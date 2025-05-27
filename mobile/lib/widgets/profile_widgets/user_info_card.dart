import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/user_model.dart';

class UserInfoCard extends StatelessWidget {
  final UserModel user;

  const UserInfoCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isEtudiant = user.role == 'ETUDIANT';
    final isAlumni = user.role == 'ALUMNI';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRow(Icons.email_outlined, user.email),
            const SizedBox(height: 8),
            _buildRow(Icons.verified_user_outlined, user.role),
            if (isEtudiant) ...[
              const Divider(height: 24),
              _buildRow(Icons.school, user.filiere ?? '—'),
              _buildRow(Icons.grade_outlined, user.niveauEtude ?? '—'),
              _buildRow(Icons.calendar_today, '${user.anneeEntree ?? '—'}'),
            ],
            if (isAlumni) ...[
              const Divider(height: 24),
              _buildRow(Icons.business_outlined, user.secteurActivite ?? '—'),
              _buildRow(Icons.badge_outlined, user.posteActuel ?? '—'),
              _buildRow(Icons.apartment_outlined, user.nomEntreprise ?? '—'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: GoogleFonts.poppins(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

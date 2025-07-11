import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/services/parcours_service.dart';
import 'package:memoire/widgets/profile_widgets/profile_header.dart';
import 'package:memoire/widgets/profile_widgets/user_info_card.dart';
import 'package:memoire/widgets/profile_widgets/user_publication_list.dart';
import 'package:memoire/screens/profile/edit_parcours_screen.dart';
import 'package:memoire/widgets/profile_widgets/parcours_display_section.dart';
import 'create_publication_screen.dart';



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService     = AuthService();
  final ParcoursService _parcoursSvc = ParcoursService();

  UserModel?                      _user;
  List<Map<String, dynamic>>     _parcoursA = [];
  List<Map<String, dynamic>>     _parcoursP = [];
  bool                           _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user     = await _authService.getUserInfo();
    final isAlumni = user.role.toUpperCase() == 'ALUMNI';


    // charger parcours
    List<Map<String, dynamic>> acad = [], prof = [];
    if (isAlumni) {
      acad = await _parcoursSvc.getParcoursAcademiques();
      prof = await _parcoursSvc.getParcoursProfessionnels();
    }

    setState(() {
      _user      = user;
      _parcoursA = acad;   // plus de filtre
      _parcoursP = prof;   // plus de filtre
      _isLoading = false;
    });

  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Mon Profil',
          style: GoogleFonts.poppins(
            color: const Color(0xFF2196F3),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF2196F3)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditParcoursScreen()),),
          ),
        ],
        iconTheme: const IconThemeData(color: Color(0xFF2196F3)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: const Color(0xFF4CAF50),
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // En-tête profil
            ProfileHeader(user: _user!),
            const SizedBox(height: 20),

            // Infos utilisateur
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: UserInfoCard(user: _user!),
            ),
            const SizedBox(height: 24),
            // Parcours (alumni uniquement)
            if (_user!.role.toUpperCase() == 'ALUMNI') ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    SectionTitle(icon: Icons.timeline, title: 'Mon Parcours'),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditParcoursScreen()),),
                      child: Text(
                        'Modifier',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (_parcoursA.isEmpty && _parcoursP.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Aucun parcours à afficher',
                    style: GoogleFonts.poppins(color: Colors.grey[600]),
                  ),
                )
              else
              // Section parcours (pour alumni)
                ParcoursDisplaySection(
                  title: 'Parcours Académiques',
                  icon: Icons.school,
                  items: _parcoursA,
                  titleField: 'diplome',
                  subtitleFields: ['institution', 'annee_obtention', 'mention'],
                ),
              ParcoursDisplaySection(
                title: 'Parcours Professionnels',
                icon: Icons.work,
                items: _parcoursP,
                titleField: 'poste',
                subtitleFields: ['entreprise', 'date_debut', 'type_contrat'],
              ),


            ],

            const SizedBox(height: 32),
            // Publications récentes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SectionTitle(
                icon: Icons.article_outlined,
                title: 'Publications récentes',
              ),
            ),
            const SizedBox(height: 12),
            UserPublicationsList(username: _user!.username),
            const SizedBox(height: 24),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreatePublicationScreen()),
          ).then((_) => _loadData());
        },
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Créer une publication',
      ),

    );
  }
}

class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const SectionTitle({required this.icon, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20, color: const Color(0xFF2196F3)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

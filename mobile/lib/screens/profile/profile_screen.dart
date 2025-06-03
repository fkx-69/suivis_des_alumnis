import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/services/parcours_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import 'package:memoire/widgets/profile_widgets/profile_header.dart';
import 'package:memoire/widgets/profile_widgets/user_info_card.dart';
import 'package:memoire/widgets/profile_widgets/parcours_section.dart';
import 'package:memoire/widgets/profile_widgets/user_publication_list.dart';
import 'package:memoire/screens/event/event_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ParcoursService _parcoursService = ParcoursService();

  UserModel? _user;
  List<Map<String, dynamic>> _parcoursA = [];
  List<Map<String, dynamic>> _parcoursP = [];
  bool _isLoading = true;
  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getUserInfo();
      List<Map<String, dynamic>> acad = [];
      List<Map<String, dynamic>> prof = [];
      if (user.role == 'ALUMNI') {
        acad = await _parcoursService.getParcoursAcademiques();
        prof = await _parcoursService.getParcoursProfessionnels();
      }
      setState(() {
        _user = user;
        _parcoursA = acad.where((p) => p['auteur'] == user.username).toList();
        _parcoursP = prof.where((p) => p['auteur'] == user.username).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EventListScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/messages');
        break;
      case 3:
      // déjà sur Profil
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Calcul pour ne pas scroll sous la BottomNavBar
    final bottomInset = kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.only(bottom: bottomInset),
        children: [
          ProfileHeader(user: _user!),
          const SizedBox(height: 16),
          UserInfoCard(user: _user!),
          const SizedBox(height: 16),
          // Publications
          UserPublicationsList(username: _user!.username),
          const SizedBox(height: 24),
          // Parcours seulement pour alumni
          if (_user!.role == 'ALUMNI') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text('Mon Parcours',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/edit_parcours'),
                    child: const Text('Modifier'),
                  ),
                ],
              ),
            ),
            ParcoursSection(
              parcoursAcademiques: _parcoursA,
              parcoursProfessionnels: _parcoursP,
              onAdd: () => Navigator.pushNamed(context, '/edit_parcours'),
              onEdit: () => Navigator.pushNamed(context, '/edit_parcours'),
            ),
          ],
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

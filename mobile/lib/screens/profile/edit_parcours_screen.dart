import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/parcours_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import 'package:memoire/widgets/profile_widgets/parcours_academique_form.dart';
import 'package:memoire/widgets/profile_widgets/parcours_professionnel_form.dart';

class EditParcoursScreen extends StatefulWidget {
  const EditParcoursScreen({super.key});

  @override
  State<EditParcoursScreen> createState() => _EditParcoursScreenState();
}

class _EditParcoursScreenState extends State<EditParcoursScreen> {
  final ParcoursService _service = ParcoursService();
  bool _isLoading = true;
  int _tabIndex = 0;
  List<Map<String, dynamic>> _acad = [];
  List<Map<String, dynamic>> _prof = [];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    _acad = await _service.getParcoursAcademiques();
    _prof = await _service.getParcoursProfessionnels();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 2,
      initialIndex: _tabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mon Parcours'),
          bottom: TabBar(
            onTap: (i) => setState(() => _tabIndex = i),
            tabs: const [
              Tab(text: 'Académique'),
              Tab(text: 'Professionnel'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Onglet Académique
            ParcoursAcademiqueFormSection(
              items: _acad,
              onCreate: (data) async {
                await _service.createParcoursAcademique(data);
                _loadAll();
              },
              onUpdate: (id, data) async {
                await _service.updateParcoursAcademique(id, data);
                _loadAll();
              },
              onDelete: (id) async {
                await _service.deleteParcoursAcademique(id);
                _loadAll();
              },
            ),

            // Onglet Professionnel
            ParcoursProfessionnelFormSection(
              items: _prof,
              onCreate: (data) async {
                await _service.createParcoursProfessionnel(data);
                _loadAll();
              },
              onUpdate: (id, data) async {
                await _service.updateParcoursProfessionnel(id, data);
                _loadAll();
              },
              onDelete: (id) async {
                await _service.deleteParcoursProfessionnel(id);
                _loadAll();
              },
            ),
          ],
        ),
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 3,
          onTap: (_) {},
        ),
      ),
    );
  }
}

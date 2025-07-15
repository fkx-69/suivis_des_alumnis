import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/parcours_service.dart';
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      initialIndex: _tabIndex,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: const BackButton(color: Color(0xFF2196F3)),
          title: Text(
            'Mon Parcours',
            style: GoogleFonts.poppins(
              color: const Color(0xFF2196F3),
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          bottom: TabBar(
            onTap: (i) => setState(() => _tabIndex = i),
            indicatorColor: const Color(0xFF4CAF50),
            indicatorWeight: 3,
            labelColor: const Color(0xFF2196F3),
            unselectedLabelColor: Colors.grey[600],
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'Académique'),
              Tab(text: 'Professionnel'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              ParcoursAcademiqueFormSection(
                items: _acad,
                onCreate: (data) async {
                  try {
                    print('✨ UI onCreate called with: $data');
                    final created = await _service.createParcoursAcademique(data);
                    print('✨ Parcours créé: $created');
                    await _loadAll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Parcours créé avec succès !'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (err) {
                    print('🚨 Erreur création parcours depuis UI: $err');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur à la création : ${err.toString()}')),
                    );
                  }
                },
                onUpdate: (id, data) async {
                  // idem si vous voulez logger les updates
                  await _service.updateParcoursAcademique(id, data);
                  await _loadAll();
                },
                onDelete: (id) async {
                  await _service.deleteParcoursAcademique(id);
                  await _loadAll();
                },
              ),


              // Professionnel
              ParcoursProfessionnelFormSection(
                items: _prof,
                onCreate: (data) async {
                  try {
                    print('✨ UI onCreate PRO payload: $data');
                    final created = await _service.createParcoursProfessionnel(data);
                    print('✨ Parcours PRO créé: $created');
                    await _loadAll();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Parcours professionnel créé avec succès !'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (err) {
                    print('🚨 Erreur création parcours PRO depuis UI: $err');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur création parcours pro : ${err.toString()}')),
                    );
                  }
                },
                onUpdate: (id, data) async {
                  await _service.updateParcoursProfessionnel(id, data);
                  await _loadAll();
                },
                onDelete: (id) async {
                  await _service.deleteParcoursProfessionnel(id);
                  await _loadAll();
                },
              ),
            ],
          ),
        ),

      ),
    );
  }
}

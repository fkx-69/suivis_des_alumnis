import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/filiere_model.dart';
import '../../../models/student_model.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/services/filiere_service.dart';
import 'package:memoire/screens/profile/profile_screen.dart';

class RegisterStudentForm extends StatefulWidget {
  const RegisterStudentForm({super.key});

  @override
  State<RegisterStudentForm> createState() => _RegisterStudentFormState();
}

class _RegisterStudentFormState extends State<RegisterStudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controllers
  final _emailController            = TextEditingController();
  final _usernameController         = TextEditingController();
  final _nomController              = TextEditingController();
  final _prenomController           = TextEditingController();
  final _passwordController         = TextEditingController();
  final _confirmPasswordController  = TextEditingController();

  // Dropdown
  List<FiliereModel> _filieres      = [];
  FiliereModel?    _selectedFiliere;
  String           _selectedNiveau  = 'L1';
  late final List<int> _annees;
  int? _selectedAnnee;


  // Toggle visibility
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

  bool   _isLoading    = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFilieres();
    _generateAnneeList();
  }

  void _generateAnneeList() {
    final current = DateTime.now().year;
    const startYear = 2016;
    // génère [2016, 2017, …, current]
    _annees = [for (var y = startYear; y <= current; y++) y];
    _selectedAnnee = _annees.last;  // par défaut l’année la plus récente
  }

  Future<void> _loadFilieres() async {
    try {
      final filieres = await FiliereService().fetchFilieres();
      setState(() {
        _filieres        = filieres;
        _selectedFiliere = filieres.isNotEmpty ? filieres.first : null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Impossible de charger les filières';
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _selectedFiliere == null) return;
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final student = StudentModel(
        email:      _emailController.text,
        username:   _usernameController.text,
        nom:        _nomController.text,
        prenom:     _prenomController.text,
        password:   _passwordController.text,
        filiere:    _selectedFiliere!.id,
        niveauEtude: _selectedNiveau,
        anneeEntree: _selectedAnnee !,
      );
      await _authService.registerEtudiant(student);
      await _authService.login(student.email, student.password);
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
            (route) => false,
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _baseDecoration({
    required String hintText,
    Widget? suffixIcon,
    bool disabled = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: disabled ? Colors.grey.shade100 : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final maxW  = constraints.maxWidth;
          final isWide = maxW > 600;
          final itemW  = isWide ? (maxW - 16) / 2 : maxW;

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              // Email
              SizedBox(
                width: itemW,
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _baseDecoration(hintText: 'Email'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Entrez votre email';
                    if (!v.contains('@')) return 'Email invalide';
                    return null;
                  },
                ),
              ),

              // Nom d'utilisateur
              SizedBox(
                width: itemW,
                child: TextFormField(
                  controller: _usernameController,
                  decoration: _baseDecoration(hintText: 'Nom d\'utilisateur'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
                ),
              ),

              // Nom
              SizedBox(
                width: itemW,
                child: TextFormField(
                  controller: _nomController,
                  decoration: _baseDecoration(hintText: 'Nom'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
                ),
              ),

              // Prénom
              SizedBox(
                width: itemW,
                child: TextFormField(
                  controller: _prenomController,
                  decoration: _baseDecoration(hintText: 'Prénom'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
                ),
              ),

              // Mot de passe
              SizedBox(
                width: itemW,
                child: TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: _baseDecoration(
                    hintText: 'Mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Entrez un mot de passe';
                    if (v.length < 6) return 'Au moins 6 caractères';
                    return null;
                  },
                ),
              ),

              // Confirmer mot de passe
              SizedBox(
                width: itemW,
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: _baseDecoration(
                    hintText: 'Confirmer le mot de passe',
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Veuillez confirmer';
                    if (v != _passwordController.text) return 'Ne correspond pas';
                    return null;
                  },
                ),
              ),

              // Filière
              SizedBox(
                width: itemW,
                child: DropdownButtonFormField<FiliereModel>(
                  value: _selectedFiliere,
                  decoration: _baseDecoration(hintText: 'Filière'),
                  items: _filieres
                      .map((f) => DropdownMenuItem<FiliereModel>(
                    value: f,
                    child: Text(f.nomComplet),
                  ))
                      .toList(),
                  onChanged: (f) => setState(() => _selectedFiliere = f),
                  validator: (_) => _selectedFiliere == null ? 'Champ requis' : null,
                ),
              ),

              // Niveau d'études
              SizedBox(
                width: itemW,
                child: DropdownButtonFormField<String>(
                  value: _selectedNiveau,
                  decoration: _baseDecoration(hintText: 'Niveau d\'études'),
                  items: niveauxEtude.entries
                      .map((e) => DropdownMenuItem<String>(
                    value: e.key,
                    child: Text(e.value),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() {
                    if (v != null) _selectedNiveau = v;
                  }),
                ),
              ),

              // Année d'entrée
              SizedBox(
                width: itemW,
                child: DropdownButtonFormField<int>(
                  value: _selectedAnnee,
                  decoration: _baseDecoration(hintText: 'Année d\'entrée'),
                  items: _annees.map((y) => DropdownMenuItem<int>(
                    value: y,
                    child: Text(y.toString()),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedAnnee = v),
                  validator: (v) => v == null ? 'Champ requis' : null,
                ),
              ),

              // Affichage d'erreur générique
              if (_errorMessage != null)
                SizedBox(
                  width: maxW,
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)),
                ),

              // Bouton S'inscrire
              SizedBox(
                width: maxW,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white)),
                  )
                      : Text('S\'inscrire',
                      style: GoogleFonts.poppins(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

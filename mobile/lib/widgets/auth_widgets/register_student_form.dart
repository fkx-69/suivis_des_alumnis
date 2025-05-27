import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/filiere_model.dart';
import '../../../models/student_model.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/services/filiere_service.dart';
import 'package:memoire/screens/profile/profile_screen.dart';
import 'package:memoire/models/user_model.dart';


class RegisterStudentForm extends StatefulWidget {
  const RegisterStudentForm({super.key});

  @override
  State<RegisterStudentForm> createState() => _RegisterStudentFormState();
}

class _RegisterStudentFormState extends State<RegisterStudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  List<FiliereModel> _filieres = [];
  FiliereModel? _selectedFiliere;
  String _selectedNiveau = 'L1';
  int _selectedAnnee = DateTime.now().year;
  bool _aBesoinMentor = false;

  @override
  void initState() {
    super.initState();
    _loadFilieres();
  }

  Future<void> _loadFilieres() async {
    try {
      final filieres = await FiliereService().fetchFilieres();
      setState(() {
        _filieres = filieres;
        _selectedFiliere = filieres.isNotEmpty ? filieres.first : null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() && _selectedFiliere != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final student = StudentModel(
          email: _emailController.text,
          username: _usernameController.text,
          nom: _nomController.text,
          prenom: _prenomController.text,
          password: _passwordController.text,
          filiere: _selectedFiliere!.id,
          niveauEtude: _selectedNiveau,
          anneeEntree: _selectedAnnee,
        );

        await _authService.registerEtudiant(student);

    // 🔐 Connexion automatique juste après
        final data = await _authService.login(student.email, student.password);

    // ✅ Ensuite aller vers profil
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                (route) => false,
          );
        }

      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(
            _emailController,
            'Email',
            Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Veuillez entrer votre email';
              if (!v.contains('@')) return 'Email invalide';
              return null;
            },
          ),

          const SizedBox(height: 16),
          _buildTextField(_usernameController, 'Nom d\'utilisateur', Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(_nomController, 'Nom', Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(_prenomController, 'Prénom', Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(_passwordController, 'Mot de passe', Icons.lock_outline, obscure: true, validator: (v) {
            if (v == null || v.isEmpty) return 'Entrez un mot de passe';
            if (v.length < 6) return 'Au moins 6 caractères';
            return null;
          }),
          const SizedBox(height: 16),
          _buildTextField(_confirmPasswordController, 'Confirmer le mot de passe', Icons.lock_outline, obscure: true, validator: (v) {
            if (v == null || v.isEmpty) return 'Confirmez le mot de passe';
            if (v != _passwordController.text) return 'Les mots de passe ne correspondent pas';
            return null;
          }),
          const SizedBox(height: 16),
          DropdownButtonFormField<FiliereModel>(
            value: _selectedFiliere,
            decoration: _dropdownDecoration('Filière', Icons.school_outlined),
            items: _filieres.map((f) => DropdownMenuItem(value: f, child: Text(f.nomComplet))).toList(),
            onChanged: (val) => setState(() => _selectedFiliere = val),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedNiveau,
            decoration: _dropdownDecoration('Niveau d\'études', Icons.grade_outlined),
            items: niveauxEtude.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedNiveau = value;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            value: _aBesoinMentor,
            onChanged: (v) => setState(() => _aBesoinMentor = v ?? false),
            activeColor: const Color(0xFF2196F3),
            title: Text('J\'ai besoin d\'un mentor', style: GoogleFonts.poppins()),
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
              ),
            ),
          ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : Text('S\'inscrire', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool obscure = false,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator ?? (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
    );
  }
}

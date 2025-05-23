import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/alumni_model.dart';
import '../../../models/filiere_model.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/services/filiere_service.dart';

class RegisterAlumniForm extends StatefulWidget {
  const RegisterAlumniForm({super.key});

  @override
  State<RegisterAlumniForm> createState() => _RegisterAlumniFormState();
}

class _RegisterAlumniFormState extends State<RegisterAlumniForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Champs
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _biographieController = TextEditingController();
  final _secteurActiviteController = TextEditingController();
  final _posteActuelController = TextEditingController();
  final _nomEntrepriseController = TextEditingController();

  List<FiliereModel> _filieres = [];
  FiliereModel? _selectedFiliere;
  String _selectedSituationPro = AlumniModel.situationsPro.keys.first;

  bool _isLoading = false;
  String? _errorMessage;

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
        _errorMessage = 'Erreur lors du chargement des filières';
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
        final alumni = AlumniModel(
          email: _emailController.text,
          username: _usernameController.text,
          nom: _nomController.text,
          prenom: _prenomController.text,
          password: _passwordController.text,
          biographie: _biographieController.text,
          filiere: _selectedFiliere!.id,
          secteurActivite: _secteurActiviteController.text,
          situationPro: _selectedSituationPro,
          posteActuel: _posteActuelController.text,
          nomEntreprise: _nomEntrepriseController.text,
        );

        await _authService.registerAlumni(alumni);

        if (mounted) {
          // redirection vers profile

        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool obscure = false,
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator ?? (value) => (value == null || value.isEmpty) ? 'Champ requis' : null,
    );
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(_emailController, 'Email', Icons.email_outlined,
              keyboardType: TextInputType.emailAddress, validator: (v) {
                if (v == null || v.isEmpty) return 'Veuillez entrer votre email';
                if (!v.contains('@')) return 'Email invalide';
                return null;
              }),
          const SizedBox(height: 16),
          _buildTextField(_usernameController, 'Nom d\'utilisateur', Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(_nomController, 'Nom', Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(_prenomController, 'Prénom', Icons.person_outline),
          const SizedBox(height: 16),
          _buildTextField(_biographieController, 'Biographie', Icons.description_outlined, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField(_passwordController, 'Mot de passe', Icons.lock_outline, obscure: true, validator: (v) {
            if (v == null || v.isEmpty) return 'Entrez un mot de passe';
            if (v.length < 6) return 'Minimum 6 caractères';
            return null;
          }),
          const SizedBox(height: 16),
          _buildTextField(_confirmPasswordController, 'Confirmer le mot de passe', Icons.lock_outline, obscure: true,
              validator: (v) {
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
          _buildTextField(_secteurActiviteController, 'Secteur d\'activité', Icons.business_outlined),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedSituationPro,
            decoration: _dropdownDecoration('Situation professionnelle', Icons.work_outline),
            items: AlumniModel.situationsPro.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (val) => setState(() => _selectedSituationPro = val ?? _selectedSituationPro),
          ),
          const SizedBox(height: 16),
          _buildTextField(_posteActuelController, 'Poste actuel', Icons.badge_outlined),
          const SizedBox(height: 16),
          _buildTextField(_nomEntrepriseController, 'Nom de l\'entreprise', Icons.business),
          const SizedBox(height: 24),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.poppins(color: Colors.red, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
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
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/alumni_model.dart';
import '../../../models/filiere_model.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/services/filiere_service.dart';
import 'package:memoire/constants/postes_par_secteur.dart';
import 'package:memoire/screens/profile/profile_screen.dart';

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
  final _secteurActiviteController = TextEditingController();
  final _posteActuelController = TextEditingController();
  final _nomEntrepriseController = TextEditingController();

  List<FiliereModel> _filieres = [];
  FiliereModel? _selectedFiliere;
  String _selectedSituationPro = AlumniModel.situationsPro.keys.first;
  String? _selectedSecteurActivite;
  String? _selectedPosteActuel;


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
          filiere: _selectedFiliere!.id,
          secteurActivite: _secteurActiviteController.text,
          situationPro: _selectedSituationPro,
          posteActuel: _posteActuelController.text,
          nomEntreprise: _nomEntrepriseController.text,
        );

        await _authService.registerAlumni(alumni);

        // 🔐 Connexion automatique juste après
        final data = await _authService.login(alumni.email, alumni.password);


        if (mounted) {
          // redirection vers profile_widgets
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                (route) => false,
          );

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
          // Situation professionnelle
          DropdownButtonFormField<String>(
            value: _selectedSituationPro,
            decoration: _dropdownDecoration('Situation professionnelle', Icons.work_outline),
            items: AlumniModel.situationsPro.entries
                .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedSituationPro = value!;
                if (value == 'chomage') {
                  _selectedSecteurActivite = null;
                  _selectedPosteActuel = null;
                  _nomEntrepriseController.clear();
                }
              });
            },
          ),
          const SizedBox(height: 16),

// Secteur d'activité (désactivé si 'chomage')
          DropdownButtonFormField<String>(
            value: _selectedSecteurActivite,
            decoration: InputDecoration(
              labelText: 'Secteur d\'activité',
              prefixIcon: const Icon(Icons.business_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: _selectedSituationPro == 'chomage'
                  ? Colors.grey.shade100
                  : Colors.white,
            ),
            items: postesParSecteur.keys
                .map((key) => DropdownMenuItem(value: key, child: Text(key)))
                .toList(),
            onChanged: _selectedSituationPro == 'chomage'
                ? null
                : (val) => setState(() {
              _selectedSecteurActivite = val;
              _selectedPosteActuel = null;
            }),
          ),

          const SizedBox(height: 16),
        // poste actuel
          DropdownButtonFormField<String>(
            value: _selectedPosteActuel,
            decoration: InputDecoration(
              labelText: 'Poste actuel',
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: _selectedSituationPro == 'chomage'
                  ? Colors.grey.shade100
                  : Colors.white,
            ),
            items: _selectedSecteurActivite != null
                ? postesParSecteur[_selectedSecteurActivite!]!
                .map((p) => DropdownMenuItem(value: p["value"], child: Text(p["label"]!)))
                .toList()
                : [],
            onChanged: _selectedSituationPro == 'chomage'
                ? null
                : (val) => setState(() => _selectedPosteActuel = val),
          ),

          const SizedBox(height: 16),

// Nom entreprise (désactivé si 'chomage')
          TextFormField(
            controller: _nomEntrepriseController,
            enabled: _selectedSituationPro != 'chomage',
            decoration: InputDecoration(
              labelText: 'Nom de l\'entreprise',
              prefixIcon: const Icon(Icons.business),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: _selectedSituationPro == 'chomage'
                  ? Colors.grey.shade100
                  : Colors.white,
            ),
          ),

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

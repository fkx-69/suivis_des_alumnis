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
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;

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
        final loginData = await _authService.login(alumni.email, alumni.password);
        print('[RegisterAlumni] loginData: $loginData');

        if (mounted) {
          // redirection vers profile_widgets
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => ProfileScreen()),
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


  // Styles partagés
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
        borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      suffixIcon: suffixIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_errorMessage != null) ...[
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
          ],

          // --- Grille responsive 1 ou 2 colonnes ---
          LayoutBuilder(
            builder: (ctx, constraints) {
              final available = constraints.maxWidth;
              final isWide    = available > 600;
              final itemW     = isWide ? (available - 16) / 2 : available;

              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
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

                  // Email
                  SizedBox(
                    width: itemW,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _baseDecoration(hintText: 'Email'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Champ requis';
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

                  // Mot de passe
                  SizedBox(
                    width: itemW,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _baseDecoration(
                        hintText: 'Mot de passe',
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
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
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Champ requis';
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
                      items: _filieres.map((f) => DropdownMenuItem<FiliereModel>(
                        value: f,
                        child: Text(f.nomComplet),
                      )).toList(),
                      onChanged: (f) => setState(() => _selectedFiliere = f),
                      validator: (_) => _selectedFiliere == null ? 'Champ requis' : null,
                    ),
                  ),

                  // Situation pro
                  SizedBox(
                    width: itemW,
                    child: DropdownButtonFormField<String>(
                      value: _selectedSituationPro,
                      decoration: _baseDecoration(hintText: 'Situation pro'),
                      items: AlumniModel.situationsPro.entries
                          .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _selectedSituationPro = v!;
                        // on vide toujours ces champs dès qu’on change
                        _selectedSecteurActivite = null;
                        _selectedPosteActuel     = null;
                        _nomEntrepriseController.clear();
                      }),
                      validator: (v) => v == null ? 'Champ requis' : null,
                    ),
                  ),

                  // Secteur d'activité — toujours visible et toujours requis
                  SizedBox(
                    width: itemW,
                    child: DropdownButtonFormField<String>(
                      value: _selectedSecteurActivite,
                      decoration: _baseDecoration(hintText: 'Secteur d\'activité'),
                      items: postesParSecteur.keys
                          .map((k) => DropdownMenuItem(
                        value: k,
                        child: Text(k),
                      ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedSecteurActivite = v),
                      validator: (v) => v == null ? 'Champ requis' : null,
                    ),
                  ),

                  // Poste actuel — activé + requis **uniquement** pour Emploi
                  // Poste actuel — activé dès qu’on est en emploi
                  SizedBox(
                    width: itemW,
                    child: DropdownButtonFormField<String>(
                      value: _selectedPosteActuel,
                      hint: const Text('Poste actuel'),
                      decoration: _baseDecoration(
                        hintText: 'Poste actuel',
                        disabled: _selectedSituationPro != 'emploi',
                      ),
                      // on propose tous les postes, quel que soit le secteur
                      items: postesParSecteur.values
                          .expand((list) => list)
                          .map((p) => DropdownMenuItem<String>(
                        value: p['value'] as String,
                        child: Text(p['label'] as String),
                      ))
                          .toList(),
                      onChanged: _selectedSituationPro == 'emploi'
                          ? (v) => setState(() => _selectedPosteActuel = v)
                          : null,
                      validator: _selectedSituationPro == 'emploi'
                          ? (v) => v == null ? 'Champ requis' : null
                          : null,
                    ),
                  ),


// Nom de l’entreprise — activé + requis pour 'emploi' **et** pour 'stage'
                  SizedBox(
                    width: itemW,
                    child: TextFormField(
                      controller: _nomEntrepriseController,
                      enabled: _selectedSituationPro == 'emploi' || _selectedSituationPro == 'stage',
                      decoration: _baseDecoration(
                        hintText: 'Nom de l\'entreprise',
                        disabled: !(_selectedSituationPro == 'emploi' || _selectedSituationPro == 'stage'),
                      ),
                      validator: (_selectedSituationPro == 'emploi' || _selectedSituationPro == 'stage')
                          ? (v) => (v == null || v.isEmpty) ? 'Champ requis' : null
                          : null,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Bouton S'inscrire (pleine largeur)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
                  : Text('S\'inscrire', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),

          const SizedBox(height: 16),

          // Lien "Connectez-vous"

        ],
      ),
    );
  }
}

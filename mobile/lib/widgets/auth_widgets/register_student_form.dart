import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/filiere_model.dart';
import '../../../models/student_model.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/services/filiere_service.dart';
import 'package:memoire/screens/main_screen.dart';
import 'package:memoire/constants/app_theme.dart';

class RegisterStudentForm extends StatefulWidget {
  const RegisterStudentForm({super.key});

  @override
  State<RegisterStudentForm> createState() => _RegisterStudentFormState();
}

class _RegisterStudentFormState extends State<RegisterStudentForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  // Controllers
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Dropdowns
  List<FiliereModel> _filieres = [];
  FiliereModel? _selectedFiliere;
  String _selectedNiveau = 'L1';
  late final List<int> _annees;
  int? _selectedAnnee;

  // UI State
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0;
  File? _photoFile;

  @override
  void initState() {
    super.initState();
    _loadFilieres();
    _generateAnneeList();
  }

  void _generateAnneeList() {
    final current = DateTime.now().year;
    const startYear = 2016;
    _annees = [for (var y = startYear; y <= current; y++) y];
    _selectedAnnee = _annees.last;
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
        _errorMessage = 'Impossible de charger les filières';
      });
    }
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _photoFile = File(img.path));
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate() || _selectedFiliere == null) return;
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
        anneeEntree: _selectedAnnee!,
        photo: _photoFile, // à adapter côté backend
      );
      await _authService.registerEtudiant(student);
      await _authService.login(student.email, student.password);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
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

  InputDecoration _baseDecoration({
    required String hintText,
    String? example,
    Widget? suffixIcon,
    bool disabled = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: disabled ? AppTheme.surfaceColor.withOpacity(0.5) : AppTheme.surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.secondary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.errorColor, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.borderColor.withOpacity(0.5), width: 1),
      ),
      suffixIcon: suffixIcon,
      helperText: example != null ? 'Exemple: $example' : null,
      helperStyle: theme.textTheme.bodySmall?.copyWith(
        color: AppTheme.subTextColor.withOpacity(0.7),
        fontSize: 12,
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: _currentStep >= 0 ? AppTheme.primaryColor : AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: _currentStep >= 1 ? AppTheme.primaryColor : AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        // Photo de profil
        GestureDetector(
          onTap: _pickPhoto,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: _photoFile != null ? FileImage(_photoFile!) : null,
              child: _photoFile == null
                  ? Icon(Icons.camera_alt, size: 32, color: Colors.grey.shade500)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _pickPhoto,
          child: Text('Choisir une photo', style: GoogleFonts.poppins(color: const Color(0xFF2196F3))),
        ),
        const SizedBox(height: 20),
        // Nom
        TextFormField(
          controller: _nomController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _baseDecoration(hintText: 'Nom', example: 'MAIGA'),
          validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
        ),
        const SizedBox(height: 16),
        // Prénom
        TextFormField(
          controller: _prenomController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _baseDecoration(hintText: 'Prénom', example: 'Hadjarata'),
          validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
        ),
        const SizedBox(height: 16),
        // Email
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _baseDecoration(hintText: 'Email', example: 'hadjara@gmail.com'),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'Veuillez entrer votre email';
            }
            final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
            if (!emailRegex.hasMatch(v)) {
              return 'Veuillez entrer un email valide (ex: nom@domaine.com)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Nom d'utilisateur
        TextFormField(
          controller: _usernameController,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _baseDecoration(hintText: 'Nom d\'utilisateur', example: 'hadjara'),
          validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      children: [
        // Mot de passe
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _baseDecoration(
            hintText: 'Mot de passe',
            example: 'MotDePasse123!',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: colorScheme.primary.withOpacity(0.6),
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'Veuillez entrer un mot de passe';
            }
            if (v.length < 6) {
              return 'Le mot de passe doit contenir au moins 6 caractères';
            }
            if (!RegExp(r'[A-Z]').hasMatch(v)) {
              return 'Le mot de passe doit contenir au moins une lettre majuscule';
            }
            if (!RegExp(r'[a-z]').hasMatch(v)) {
              return 'Le mot de passe doit contenir au moins une lettre minuscule';
            }
            if (!RegExp(r'[0-9]').hasMatch(v)) {
              return 'Le mot de passe doit contenir au moins un chiffre';
            }
            if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) {
              return 'Le mot de passe doit contenir au moins un caractère spécial (!@#\$%^&*)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Confirmation
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _baseDecoration(
            hintText: 'Confirmer le mot de passe',
            example: 'MotDePasse123!',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: colorScheme.primary.withOpacity(0.6),
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) {
              return 'Veuillez confirmer votre mot de passe';
            }
            if (v != _passwordController.text) {
              return 'Les mots de passe ne correspondent pas';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Filière
        DropdownButtonFormField<FiliereModel>(
          value: _selectedFiliere,
          decoration: _baseDecoration(hintText: 'Filière'),
          items: _filieres.map((f) => DropdownMenuItem(value: f, child: Text(f.nomComplet))).toList(),
          onChanged: (f) => setState(() => _selectedFiliere = f),
          validator: (_) => _selectedFiliere == null ? 'Champ requis' : null,
        ),
        const SizedBox(height: 16),
        // Niveau d'étude
        DropdownButtonFormField<String>(
          value: _selectedNiveau,
          decoration: _baseDecoration(hintText: 'Niveau d\'étude'),
          items: niveauxEtude.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) => setState(() => _selectedNiveau = v!),
        ),
        const SizedBox(height: 16),
        // Année d'entrée
        DropdownButtonFormField<int>(
          value: _selectedAnnee,
          decoration: _baseDecoration(hintText: 'Année d\'entrée'),
          items: _annees.map((y) => DropdownMenuItem(value: y, child: Text(y.toString()))).toList(),
          onChanged: (v) => setState(() => _selectedAnnee = v),
          validator: (v) => v == null ? 'Champ requis' : null,
        ),
      ],
    );
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() => _currentStep = 1);
    }
  }

  void _previousStep() {
    setState(() => _currentStep = 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: AppTheme.errorColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: textTheme.bodyMedium?.copyWith(color: AppTheme.errorColor),
                    ),
                  ),
                ],
              ),
            ),
          _buildStepIndicator(),
          _currentStep == 0 ? _buildStep1() : _buildStep2(),
          const SizedBox(height: 32),
          Row(
            children: [
              if (_currentStep > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _previousStep,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 20),
                        const SizedBox(width: 8),
                        Text('Précédent'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_currentStep == 0 ? _nextStep : _register),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.secondary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _currentStep == 0 ? Icons.arrow_forward : Icons.person_add,
                              size: 20,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currentStep == 0 ? 'Suivant' : 'S\'inscrire',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import '../../../models/alumni_model.dart';
import '../../../models/filiere_model.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/services/filiere_service.dart';
import 'package:memoire/constants/postes_par_secteur.dart';
import 'package:memoire/screens/main_screen.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RegisterAlumniForm extends StatefulWidget {
  const RegisterAlumniForm({super.key});

  @override
  State<RegisterAlumniForm> createState() => _RegisterAlumniFormState();
}

class _RegisterAlumniFormState extends State<RegisterAlumniForm> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _imagePicker = ImagePicker();

  // Controllers
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _secteurActiviteController = TextEditingController();
  final _posteActuelController = TextEditingController();
  final _nomEntrepriseController = TextEditingController();

  // Dropdowns
  List<FiliereModel> _filieres = [];
  FiliereModel? _selectedFiliere;
  String _selectedSituationPro = AlumniModel.situationsPro.keys.first;
  String? _selectedSecteurActivite;
  String? _selectedPosteActuel;

  // UI State
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0; // 0 = Étape 1, 1 = Étape 2, 2 = Étape 3
  File? _selectedImage;

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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sélection de l\'image';
      });
    }
  }

  bool _canProceedToStep2() {
    return _emailController.text.isNotEmpty &&
           _usernameController.text.isNotEmpty &&
           _nomController.text.isNotEmpty &&
           _prenomController.text.isNotEmpty;
  }

  bool _canProceedToStep3() {
    return _passwordController.text.isNotEmpty &&
           _confirmPasswordController.text.isNotEmpty &&
           _selectedFiliere != null;
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      if (_currentStep == 0 && _canProceedToStep2()) {
        setState(() {
          _currentStep = 1;
        });
      } else if (_currentStep == 1 && _canProceedToStep3()) {
        setState(() {
          _currentStep = 2;
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
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
        final loginData = await _authService.login(alumni.email, alumni.password);

        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => MainScreen()),
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
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: _currentStep >= 2 ? AppTheme.primaryColor : AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTitle() {
    final titles = [
      'Informations personnelles',
      'Sécurité & Formation',
      'Carrière professionnelle'
    ];
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Text(
        titles[_currentStep],
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        // Photo de profil
        Container(
          margin: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              Text(
                'Photo de profil',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(60),
                    border: Border.all(
                      color: AppTheme.borderColor,
                      width: 2,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(58),
                          child: Image.file(
                            _selectedImage!,
                            width: 116,
                            height: 116,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: AppTheme.subTextColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ajouter une photo',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.subTextColor,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),

        // Nom et Prénom
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nomController,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: _baseDecoration(
                  hintText: 'Nom',
                  example: 'MAIGA',
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _prenomController,
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: _baseDecoration(
                  hintText: 'Prénom',
                  example: 'Hadjarata',
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Email
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _baseDecoration(
            hintText: 'Email',
            example: 'hadjara@gmail.com',
          ),
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
        const SizedBox(height: 20),

        // Nom d'utilisateur
        TextFormField(
          controller: _usernameController,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _baseDecoration(
            hintText: 'Nom d\'utilisateur',
            example: 'hadjara',
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        // Mot de passe
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _baseDecoration(
            hintText: 'Mot de passe',
            example: 'MotDePasse123!',
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                size: 20,
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
            if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v)) {
              return 'Le mot de passe doit contenir au moins un caractère spécial (!@#\$%^&*)';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        // Confirmer mot de passe
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.next,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _baseDecoration(
            hintText: 'Confirmer le mot de passe',
            example: 'MotDePasse123!',
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                size: 20,
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
        const SizedBox(height: 20),

        // Filière
        DropdownButtonFormField<FiliereModel>(
          value: _selectedFiliere,
          decoration: _baseDecoration(hintText: 'Filière'),
          items: _filieres.map((f) => DropdownMenuItem<FiliereModel>(
            value: f,
            child: Text(f.nomComplet),
          )).toList(),
          onChanged: (f) => setState(() => _selectedFiliere = f),
          validator: (_) => _selectedFiliere == null ? 'Champ requis' : null,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        // Situation professionnelle
        DropdownButtonFormField<String>(
          value: _selectedSituationPro,
          decoration: _baseDecoration(
            hintText: 'Situation professionnelle',
            example: 'En emploi, En recherche, Entrepreneur...',
          ),
          items: AlumniModel.situationsPro.entries
              .map((e) => DropdownMenuItem(
            value: e.key,
            child: Text(e.value),
          ))
              .toList(),
          onChanged: (v) => setState(() {
            _selectedSituationPro = v!;
            _selectedSecteurActivite = null;
            _selectedPosteActuel = null;
            _nomEntrepriseController.clear();
          }),
          validator: (v) => v == null ? 'Champ requis' : null,
        ),
        const SizedBox(height: 20),

        // Secteur d'activité
        DropdownButtonFormField<String>(
          value: _selectedSecteurActivite,
          decoration: _baseDecoration(
            hintText: 'Secteur d\'activité',
            example: 'Informatique, Finance, Marketing...',
          ),
          items: postesParSecteur.keys
              .map((k) => DropdownMenuItem(
            value: k,
            child: Text(k),
          ))
              .toList(),
          onChanged: (v) => setState(() => _selectedSecteurActivite = v),
          validator: (v) => v == null ? 'Champ requis' : null,
        ),
        const SizedBox(height: 20),

        // Poste actuel (si en emploi)
        if (_selectedSituationPro == 'emploi') ...[
          DropdownButtonFormField<String>(
            value: _selectedPosteActuel,
            decoration: _baseDecoration(
              hintText: 'Poste actuel',
              example: 'Développeur, Manager, Consultant...',
            ),
            items: postesParSecteur.values
                .expand((list) => list)
                .map((p) => DropdownMenuItem<String>(
              value: p['value'] as String,
              child: Text(p['label'] as String),
            ))
                .toList(),
            onChanged: (v) => setState(() => _selectedPosteActuel = v),
            validator: (v) => v == null ? 'Champ requis' : null,
          ),
          const SizedBox(height: 20),
        ],

        // Nom de l'entreprise
        TextFormField(
          controller: _nomEntrepriseController,
          textInputAction: TextInputAction.done,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: _baseDecoration(
            hintText: 'Nom de l\'entreprise',
            example: 'Google, Microsoft, Startup XYZ...',
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Message d'erreur
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.errorColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.errorColor,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppTheme.errorColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Indicateur d'étape
          _buildStepIndicator(),
          
          // Titre de l'étape
          _buildStepTitle(),

          // Contenu de l'étape
          if (_currentStep == 0) _buildStep1()
          else if (_currentStep == 1) _buildStep2()
          else _buildStep3(),

          const SizedBox(height: 32),

          // Boutons de navigation
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
                  onPressed: _isLoading ? null : (_currentStep < 2 ? _nextStep : _register),
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
                        _currentStep < 2 ? Icons.arrow_forward : Icons.person_add,
                        size: 20,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentStep < 2 ? 'Suivant' : 'S\'inscrire',
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

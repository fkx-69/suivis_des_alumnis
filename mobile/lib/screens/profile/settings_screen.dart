import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../screens/auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Se déconnecter'),
            onTap: () async {
              await AuthService().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Changer email ou mot de passe'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ChangeCredentialsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ChangeCredentialsScreen extends StatefulWidget {
  const ChangeCredentialsScreen({Key? key}) : super(key: key);

  @override
  State<ChangeCredentialsScreen> createState() => _ChangeCredentialsScreenState();
}

class _ChangeCredentialsScreenState extends State<ChangeCredentialsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isVerifying = false;
  bool _isVerified = false;
  String? _error;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newEmailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyPassword() async {
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    final ok = await AuthService().verifyPassword(_currentPasswordController.text);
    setState(() {
      _isVerifying = false;
      _isVerified = ok;
      if (!ok) _error = 'Mot de passe incorrect';
    });
  }

  Future<void> _changeCredentials() async {
    setState(() => _error = null);
    bool changed = false;
    if (_newEmailController.text.isNotEmpty) {
      final ok = await AuthService().changeEmail(_newEmailController.text, _currentPasswordController.text);
      if (!ok) {
        setState(() => _error = "Erreur lors du changement d'email");
        return;
      }
      changed = true;
    }
    if (_newPasswordController.text.isNotEmpty) {
      final ok = await AuthService().changePassword(_currentPasswordController.text, _newPasswordController.text);
      if (!ok) {
        setState(() => _error = "Erreur lors du changement de mot de passe");
        return;
      }
      changed = true;
    }
    if (changed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Identifiants modifiés avec succès.')));
      Navigator.of(context).pop();
    } else {
      setState(() => _error = 'Aucune modification à effectuer.');
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 8) return 'Au moins 8 caractères';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Au moins une majuscule';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Au moins une minuscule';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Au moins un chiffre';
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) return 'Au moins un caractère spécial';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Changer mes identifiants')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          
          child: !_isVerified
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Veuillez valider votre mot de passe actuel pour continuer.'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
                      validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isVerifying
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                _verifyPassword();
                              }
                            },
                      child: _isVerifying
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Valider'),
                    ),
                  ],
                )
              : Column(
                  children: [
                    const Text('Changer mon email et/ou mon mot de passe'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newEmailController,
                      decoration: const InputDecoration(labelText: 'Nouvel email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                      validator: _validatePassword,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _changeCredentials();
                        }
                      },
                      child: const Text('Enregistrer les modifications'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
} 
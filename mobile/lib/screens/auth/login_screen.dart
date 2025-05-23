import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/services/auth_service.dart';
import 'widgets/login_form.dart';
import 'widgets/signup_link.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final response = await _authService.login(
          _emailController.text,
          _passwordController.text,
        );

        // configurer le bouton de redirection
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.school, size: 80, color: Color(0xFF2196F3)),
              const SizedBox(height: 24),
              Text('Connexion',
                  style: GoogleFonts.poppins(
                      fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF2196F3))),
              const SizedBox(height: 40),
              LoginForm(
                formKey: _formKey,
                emailController: _emailController,
                passwordController: _passwordController,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                onLogin: _login,
              ),
              const SizedBox(height: 16),
              SignupLink(onTap: () {
                // TODO: Naviguer vers la page d'inscription
              }),
            ],
          ),
        ),
      ),
    );
  }
}

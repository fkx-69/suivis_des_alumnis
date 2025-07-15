import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'package:memoire/services/auth_service.dart';
import 'package:memoire/widgets/profile_widgets/edit_profile_form.dart';
import 'package:memoire/constants/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;
  int _selectedIndex = 3; // Profil

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    try {
      final u = await _authService.getUserInfo();
      setState(() => _user = u);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/events');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/messages');
        break;
      case 3:
        Navigator.pop(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _user == null) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 1,
        leading: BackButton(color: AppTheme.primaryColor),
        title: Text(
          'Modifier le profil',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: EditProfileForm(
                user: _user!,
                onSaved: (updatedUser) {
                  Navigator.pop(context, updatedUser);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

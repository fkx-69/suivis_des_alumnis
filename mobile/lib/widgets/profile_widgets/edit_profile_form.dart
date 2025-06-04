import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import 'package:memoire/screens/profile/edit_profile_screen.dart';

class EditProfileForm extends StatefulWidget {
  final UserModel user;
  final ValueChanged<UserModel> onSaved;

  const EditProfileForm({
    super.key,
    required this.user,
    required this.onSaved,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _prenomCtl;
  late TextEditingController _nomCtl;
  late TextEditingController _usernameCtl;
  late TextEditingController _bioCtl;
  File? _photoFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _prenomCtl    = TextEditingController(text: widget.user.prenom);
    _nomCtl       = TextEditingController(text: widget.user.nom);
    _usernameCtl  = TextEditingController(text: widget.user.username);
    _bioCtl       = TextEditingController(text: widget.user.biographie ?? '');
  }

  @override
  void dispose() {
    _prenomCtl.dispose();
    _nomCtl.dispose();
    _usernameCtl.dispose();
    _bioCtl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _photoFile = File(img.path));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final updated = await AuthService().updateProfile(
        prenom: _prenomCtl.text.trim(),
        nom: _nomCtl.text.trim(),
        username: _usernameCtl.text.trim(),
        biographie: _bioCtl.text.trim(),
        photo: _photoFile,
      );
      widget.onSaved(updated);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Photo de profil
          GestureDetector(
            onTap: _pickPhoto,
            child: CircleAvatar(
              radius: 48,
              backgroundImage: _photoFile != null
                  ? FileImage(_photoFile!)
                  : (widget.user.photoProfil != null
                  ? NetworkImage(widget.user.photoProfil!)
                  : const AssetImage('assets/images/default_avatar.png'))
              as ImageProvider,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _pickPhoto,
            child: Text('Changer Photo', style: GoogleFonts.poppins()),
          ),
          const SizedBox(height: 24),

          // Prénom
          TextFormField(
            controller: _prenomCtl,
            decoration: const InputDecoration(labelText: 'Prénom'),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),

          // Nom
          TextFormField(
            controller: _nomCtl,
            decoration: const InputDecoration(labelText: 'Nom'),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),

          // Username
          TextFormField(
            controller: _usernameCtl,
            decoration: const InputDecoration(labelText: 'Nom d’utilisateur'),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),

          // Biographie
          TextFormField(
            controller: _bioCtl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Biographie'),
          ),
          const SizedBox(height: 32),

          // Bouton enregistrer
          _isSaving
              ? const CircularProgressIndicator()
              : SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: const Text('Enregistrer'),
            ),
          ),
        ],
      ),
    );
  }
}

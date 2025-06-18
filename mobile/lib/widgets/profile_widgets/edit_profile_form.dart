import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

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
    _prenomCtl   = TextEditingController(text: widget.user.prenom);
    _nomCtl      = TextEditingController(text: widget.user.nom);
    _usernameCtl = TextEditingController(text: widget.user.username);
    _bioCtl      = TextEditingController(text: widget.user.biographie ?? '');
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
    if (img != null) setState(() => _photoFile = File(img.path));
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Photo & bouton
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _photoFile != null
                        ? FileImage(_photoFile!) as ImageProvider
                        : (widget.user.photoProfil != null
                        ? NetworkImage(widget.user.photoProfil!)
                        : const AssetImage('assets/images/default_avatar.png'))
                    as ImageProvider,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _pickPhoto,
                child: Text('Changer la photo', style: GoogleFonts.poppins(color: const Color(0xFF2196F3))),
              ),
              const SizedBox(height: 24),

              // Prénom
              TextFormField(
                controller: _prenomCtl,
                decoration: _inputDecoration('Prénom'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // Nom
              TextFormField(
                controller: _nomCtl,
                decoration: _inputDecoration('Nom'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // Username
              TextFormField(
                controller: _usernameCtl,
                decoration: _inputDecoration('Nom d’utilisateur'),
                validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),

              // Biographie
              TextFormField(
                controller: _bioCtl,
                maxLines: 3,
                decoration: _inputDecoration('Biographie'),
              ),
              const SizedBox(height: 32),

              // Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                child: _isSaving
                    ? const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator()),
                )
                    : ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Enregistrer',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

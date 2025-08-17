import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:memoire/services/upload_service.dart';

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
  XFile? _photoFile;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _prenomCtl = TextEditingController(text: widget.user.prenom);
    _nomCtl = TextEditingController(text: widget.user.nom);
    _usernameCtl = TextEditingController(text: widget.user.username);
    _bioCtl = TextEditingController(text: widget.user.biographie ?? '');
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
    print('📸 EditProfileForm: Sélection d\'une photo...');
    try {
      final img = await UploadService.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (img != null) {
        print('📸 EditProfileForm: Photo sélectionnée: ${img.name}');
        setState(() => _photoFile = img);
      }
    } catch (e) {
      print('❌ EditProfileForm: Erreur lors de la sélection de photo: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection de photo: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    print('💾 EditProfileForm: Sauvegarde du profil...');
    print('   Photo sélectionnée: ${_photoFile?.path}');
    print('   Photo sélectionnée - nom: ${_photoFile?.name}');
    print('   Photo sélectionnée - taille: ${_photoFile != null ? await _photoFile!.length() : 'N/A'} bytes');
    print('   Photo existante: ${widget.user.photoProfil}');
    print('   Prénom: ${_prenomCtl.text.trim()}');
    print('   Nom: ${_nomCtl.text.trim()}');
    print('   Username: ${_usernameCtl.text.trim()}');
    print('   Biographie: ${_bioCtl.text.trim()}');
    
    setState(() => _isSaving = true);
    try {
      final updated = await AuthService().updateProfile(
        prenom: _prenomCtl.text.trim(),
        nom: _nomCtl.text.trim(),
        username: _usernameCtl.text.trim(),
        biographie: _bioCtl.text.trim(),
        photo: _photoFile,
      );
      
      print('✅ EditProfileForm: Profil mis à jour avec succès');
      print('   Nouvelle photo: ${updated.photoProfil}');
      print('   Nouveau prénom: ${updated.prenom}');
      print('   Nouveau nom: ${updated.nom}');
      
      widget.onSaved(updated);
      
      // Afficher un message de succès
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profil mis à jour avec succès'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ EditProfileForm: Erreur lors de la sauvegarde: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
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
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 2,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.surfaceColor,
                backgroundImage: _buildProfileImage(),
                child: _buildProfileFallback(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.camera_alt, size: 16),
            label: const Text(
              'Changer la photo',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Prénom
          TextFormField(
            controller: _prenomCtl,
            decoration: const InputDecoration(
              labelText: 'Prénom',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),

          // Nom
          TextFormField(
            controller: _nomCtl,
            decoration: const InputDecoration(
              labelText: 'Nom',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),

          // Username
          TextFormField(
            controller: _usernameCtl,
            decoration: const InputDecoration(
              labelText: 'Nom d\'utilisateur',
              border: OutlineInputBorder(),
            ),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),

          // Biographie
          TextFormField(
            controller: _bioCtl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Biographie',
              border: OutlineInputBorder(),
              hintText: 'Parlez-nous de vous...',
            ),
          ),
          const SizedBox(height: 32),

          // Bouton Enregistrer
          SizedBox(
            width: double.infinity,
            height: 48,
            child: _isSaving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Enregistrer',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _buildProfileImage() {
    try {
      // Priorité 1: Photo nouvellement sélectionnée
      if (_photoFile != null) {
        print('🖼️ Affichage de la photo sélectionnée: ${_photoFile!.name}');
        return FileImage(File(_photoFile!.path));
      }
      
      // Priorité 2: Photo existante depuis le serveur
      if (widget.user.photoProfil != null && widget.user.photoProfil!.isNotEmpty) {
        print('🖼️ Affichage de la photo existante: ${widget.user.photoProfil}');
        return NetworkImage(widget.user.photoProfil!);
      }
      
      print('🖼️ Aucune photo disponible, affichage des initiales');
      return null;
    } catch (e) {
      print('❌ Erreur lors de la construction de l\'image: $e');
      return null;
    }
  }

  Widget? _buildProfileFallback() {
    // Afficher les initiales seulement si aucune photo n'est disponible
    if (_photoFile == null && 
        (widget.user.photoProfil == null || widget.user.photoProfil!.isEmpty)) {
      return Text(
        '${widget.user.prenom[0]}${widget.user.nom[0]}'.toUpperCase(),
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: AppTheme.subTextColor,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return null;
  }
}

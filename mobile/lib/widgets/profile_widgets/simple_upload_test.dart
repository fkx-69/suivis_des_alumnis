import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:memoire/services/auth_service.dart';

class SimpleUploadTest extends StatefulWidget {
  const SimpleUploadTest({super.key});

  @override
  State<SimpleUploadTest> createState() => _SimpleUploadTestState();
}

class _SimpleUploadTestState extends State<SimpleUploadTest> {
  File? _selectedFile;
  bool _isUploading = false;
  String _result = '';

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedFile = File(pickedFile.path);
          _result = 'Fichier sélectionné: ${pickedFile.path}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Erreur sélection: $e';
      });
    }
  }

  Future<void> _testSimpleUpload() async {
    if (_selectedFile == null) {
      setState(() {
        _result = 'Aucun fichier sélectionné';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _result = 'Upload en cours...';
    });

    try {
      print('🧪 SIMPLE UPLOAD - Début');
      print('   Fichier: ${_selectedFile!.path}');
      
      final authService = AuthService();
      final currentUser = await authService.getUserInfo();
      
      print('🧪 SIMPLE UPLOAD - Utilisateur: ${currentUser.username}');
      
      // Test simple sans vérifications
      final updatedUser = await authService.updateProfile(
        prenom: currentUser.prenom,
        nom: currentUser.nom,
        username: currentUser.username,
        biographie: currentUser.biographie,
        photo: _selectedFile,
      );
      
      print('🧪 SIMPLE UPLOAD - Succès!');
      print('   Photo: ${updatedUser.photoProfil}');
      
      setState(() {
        _result = '''
✅ Upload réussi!

📸 Photo: ${updatedUser.photoProfil ?? 'Non définie'}
👤 User: ${updatedUser.username}
''';
      });
      
    } catch (e) {
      print('🧪 SIMPLE UPLOAD - Erreur: $e');
      setState(() {
        _result = '''
❌ Erreur d'upload:

$e

🔍 Type d'erreur: ${e.runtimeType}
''';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Upload Simple'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Test Upload Simple',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version simplifiée sans vérifications problématiques',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Sélectionner une photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _selectedFile != null && !_isUploading ? _testSimpleUpload : null,
              icon: _isUploading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload),
              label: Text(_isUploading ? 'Upload en cours...' : 'Tester upload simple'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_result.isNotEmpty)
              Card(
                color: _result.contains('✅') 
                  ? Colors.green.shade50 
                  : _result.contains('❌') 
                    ? Colors.red.shade50 
                    : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _result.contains('✅') 
                              ? Icons.check_circle 
                              : _result.contains('❌')
                                ? Icons.error
                                : Icons.info,
                            color: _result.contains('✅') 
                              ? Colors.green 
                              : _result.contains('❌')
                                ? Colors.red
                                : Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _result.contains('✅') 
                              ? 'Succès' 
                              : _result.contains('❌')
                                ? 'Erreur'
                                : 'Information',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _result.contains('✅') 
                                ? Colors.green 
                                : _result.contains('❌')
                                  ? Colors.red
                                  : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 
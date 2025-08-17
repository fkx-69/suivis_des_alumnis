import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:memoire/services/auth_service.dart';

class UploadTestWidget extends StatefulWidget {
  const UploadTestWidget({super.key});

  @override
  State<UploadTestWidget> createState() => _UploadTestWidgetState();
}

class _UploadTestWidgetState extends State<UploadTestWidget> {
  File? _selectedFile;
  bool _isUploading = false;
  String _uploadResult = '';
  String _fileInfo = '';

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          _selectedFile = file;
          _uploadResult = '';
          _fileInfo = _getFileInfo(file);
        });
      }
    } catch (e) {
      setState(() {
        _uploadResult = 'Erreur lors de la sélection: $e';
      });
    }
  }

  String _getFileInfo(File file) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileSize = file.lengthSync();
    final fileSizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);
    
    return '''
📁 Nom: $fileName
📏 Taille: ${fileSize} bytes ($fileSizeMB MB)
📍 Chemin: ${file.path}
''';
  }

  Future<void> _testUpload() async {
    if (_selectedFile == null) {
      setState(() {
        _uploadResult = 'Aucun fichier sélectionné';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadResult = 'Test d\'upload en cours...';
    });

    try {
      print('🧪 TEST UPLOAD - Début du test');
      print('   Fichier: ${_selectedFile!.path}');
      
      final authService = AuthService();
      final currentUser = await authService.getUserInfo();
      
      print('🧪 TEST UPLOAD - Utilisateur actuel: ${currentUser.username}');
      
      final updatedUser = await authService.updateProfile(
        prenom: currentUser.prenom,
        nom: currentUser.nom,
        username: currentUser.username,
        biographie: currentUser.biographie,
        photo: _selectedFile,
      );
      
      print('🧪 TEST UPLOAD - Succès!');
      print('   Nouvelle photo: ${updatedUser.photoProfil}');
      
      setState(() {
        _uploadResult = '''
✅ Upload réussi!

📸 Nouvelle photo: ${updatedUser.photoProfil ?? 'Non définie'}
👤 Utilisateur mis à jour: ${updatedUser.username}
''';
      });
      
    } catch (e) {
      print('🧪 TEST UPLOAD - Erreur: $e');
      setState(() {
        _uploadResult = '''
❌ Erreur d'upload:

$e

🔍 Vérifiez:
- La connexion au serveur
- La taille du fichier (max 10MB)
- Le type de fichier (JPG, PNG, GIF)
- Les permissions du serveur
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
        title: const Text('Test Upload Photo'),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test d\'Upload de Photo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ce widget permet de tester l\'upload de photo et diagnostiquer les problèmes.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.subTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Sélection de fichier
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
            
            // Informations sur le fichier
            if (_selectedFile != null) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Fichier sélectionné',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _fileInfo,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Bouton de test
            ElevatedButton.icon(
              onPressed: _selectedFile != null && !_isUploading ? _testUpload : null,
              icon: _isUploading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload),
              label: Text(_isUploading ? 'Upload en cours...' : 'Tester l\'upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            
            // Résultat
            if (_uploadResult.isNotEmpty) ...[
              Card(
                color: _uploadResult.contains('✅') 
                  ? Colors.green.shade50 
                  : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _uploadResult.contains('✅') ? Icons.check_circle : Icons.error,
                            color: _uploadResult.contains('✅') ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _uploadResult.contains('✅') ? 'Succès' : 'Erreur',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _uploadResult.contains('✅') ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _uploadResult,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 
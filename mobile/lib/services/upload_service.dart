import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class UploadService {
  static final ImagePicker _picker = ImagePicker();

  /// Sélectionne une image adaptée pour web et mobile
  static Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      if (kIsWeb) {
        // Configuration spécifique pour le web
        return await _picker.pickImage(
          source: source,
          maxWidth: maxWidth ?? 800,
          maxHeight: maxHeight ?? 800,
          imageQuality: imageQuality ?? 80,
        );
      } else {
        // Configuration pour mobile
        return await _picker.pickImage(
          source: source,
          maxWidth: maxWidth ?? 800,
          maxHeight: maxHeight ?? 800,
          imageQuality: imageQuality ?? 80,
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la sélection d\'image: $e');
      return null;
    }
  }

  /// Convertit un XFile en MultipartFile pour l'upload
  static Future<MultipartFile?> createMultipartFile(XFile file) async {
    try {
      if (kIsWeb) {
        // Pour le web, on lit les bytes
        final bytes = await file.readAsBytes();
        return MultipartFile.fromBytes(
          bytes,
          filename: file.name,
        );
      } else {
        // Pour mobile, on utilise le fichier directement
        return MultipartFile.fromFile(
          file.path,
          filename: file.name,
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la création du MultipartFile: $e');
      return null;
    }
  }

  /// Vérifie si une image est valide
  static bool isValidImage(XFile file) {
    final fileName = file.name.toLowerCase();
    final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
    
    return validExtensions.any((ext) => fileName.endsWith(ext));
  }

  /// Obtient les informations sur le fichier
  static Future<Map<String, dynamic>> getFileInfo(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final sizeInBytes = bytes.length;
      final sizeInMB = sizeInBytes / (1024 * 1024);
      
      return {
        'name': file.name,
        'size': sizeInBytes,
        'sizeMB': sizeInMB,
        'isValid': isValidImage(file),
        'isWeb': kIsWeb,
      };
    } catch (e) {
      print('❌ Erreur lors de l\'obtention des infos du fichier: $e');
      return {
        'name': file.name,
        'size': 0,
        'sizeMB': 0,
        'isValid': false,
        'isWeb': kIsWeb,
        'error': e.toString(),
      };
    }
  }

  /// Crée un FormData avec une image
  static Future<FormData?> createFormDataWithImage({
    required Map<String, dynamic> data,
    XFile? imageFile,
    String imageFieldName = 'photo',
  }) async {
    try {
      final Map<String, dynamic> formDataMap = Map.from(data);
      
      if (imageFile != null) {
        final multipartFile = await createMultipartFile(imageFile);
        if (multipartFile != null) {
          formDataMap[imageFieldName] = multipartFile;
        } else {
          throw Exception('Impossible de créer le MultipartFile');
        }
      }
      
      return FormData.fromMap(formDataMap);
    } catch (e) {
      print('❌ Erreur lors de la création du FormData: $e');
      return null;
    }
  }
} 
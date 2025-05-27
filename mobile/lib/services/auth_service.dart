import '../helpers/token_manager.dart';
import 'package:memoire/services/dio_client.dart';
import 'package:memoire/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:memoire/models/alumni_model.dart';
import 'package:memoire/models/student_model.dart';
import 'package:memoire/models/user_model.dart';
import 'dart:io';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['access'] != null && data['refresh'] != null) {
          await TokenManager.saveTokens(data['access'], data['refresh']);
        }

        return data;
      } else {
        throw Exception('Échec de la connexion: ${response.data}');
      }
    } on DioException catch (e) {
      final error = e.response?.data['detail'] ?? 'Erreur de connexion';
      throw Exception(error);
    }
  }
  Future<void> logout() async {
    await TokenManager.clearTokens();
    // Tu peux aussi naviguer vers LoginScreen ici si besoin
  }
  Future<Map<String, dynamic>> registerEtudiant(StudentModel etudiant) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.registerEtudiant,
        data: etudiant.toJson(),
      );

      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Échec de l\'inscription: ${response.data}');
      }
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      final erreurs = e.response?.data['errors'];
      String message = 'Erreur d\'inscription';

      if (detail != null) {
        message = detail.toString();
      } else if (erreurs is Map) {
        message = erreurs.entries.map((e) => '${e.key}: ${e.value}').join('\n');
      } else if (e.response?.data is Map && e.response!.data.values.isNotEmpty) {
        message = e.response!.data.values.first.toString();
      }

      throw Exception(message);
    }
  }
  Future<Map<String, dynamic>> registerAlumni(AlumniModel alumni) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.registerAlumni,
        data: alumni.toJson(),
      );

      if (response.statusCode == 201) return response.data;

      throw Exception('Échec de l\'inscription: ${response.data}');
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      final erreurs = e.response?.data['errors'];
      String message = 'Erreur d\'inscription';

      if (detail != null) {
        message = detail.toString();
      } else if (erreurs is Map) {
        message = erreurs.entries.map((e) => '${e.key}: ${e.value}').join('\n');
      } else if (e.response?.data is Map && e.response!.data.values.isNotEmpty) {
        message = e.response!.data.values.first.toString();
      }

      throw Exception(message);
    }
  }

  /// 🔐 Récupère les infos utilisateur connecté
  Future<UserModel> getUserInfo() async {
    try {
      final response = await DioClient.dio.get(ApiConstants.userInfo);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message = e.response?.data['detail'] ?? 'Erreur de récupération utilisateur';
      throw Exception(message.toString());
    }
  }

  Future<UserModel> updateProfile({
    required String prenom,
    required String nom,
    required String username,
    String? biographie,
    File? photo,
  }) async {
    try {
      // Préparation des données
      final formData = FormData.fromMap({
        'prenom': prenom,
        'nom': nom,
        'username': username,
        if (biographie != null) 'biographie': biographie,
        if (photo != null)
          'photo': await MultipartFile.fromFile(
            photo.path,
            filename: photo.path.split(Platform.pathSeparator).last,
          ),
      });

      final response = await DioClient.dio.put(
        ApiConstants.userUpdate, // doit être "/accounts/me/update/"
        data: formData,
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data['detail'] ?? 'Erreur de mise à jour du profil';
      throw Exception(message.toString());
    }
  }
  }





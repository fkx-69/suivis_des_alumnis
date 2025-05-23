import '../helpers/token_manager.dart';
import 'package:memoire/services/dio_client.dart';
import 'package:memoire/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:memoire/models/alumni_model.dart';
import 'package:memoire/models/student_model.dart';

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

}

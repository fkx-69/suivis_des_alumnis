import 'package:dio/dio.dart';
import 'package:memoire/services/dio_client.dart';
import '../constants/api_constants.dart';

class ParcoursService {
  final Dio _dio = DioClient.dio;

  // -- Académique --

  Future<List<Map<String, dynamic>>> getParcoursAcademiques() async {
    try {
      final resp = await _dio.get(ApiConstants.parcoursAcademiquesList);
      return List<Map<String, dynamic>>.from(resp.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Erreur chargement parcours académiques');
    }
  }

  Future<Map<String, dynamic>> getParcoursAcademique(int id) async {
    final url = ApiConstants.parcoursAcademiquesRead.replaceFirst('{id}', '$id');
    try {
      final resp = await _dio.get(url);
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Erreur lecture parcours académique');
    }
  }

  Future<Map<String, dynamic>> createParcoursAcademique(Map<String, dynamic> data) async {
    print('📤 createParcoursAcademique payload: $data');
    try {
      final resp = await _dio.post(
        ApiConstants.parcoursAcademiquesCreate,
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
      print('✅ createParcoursAcademique response: ${resp.data}');
      return resp.data;
    } on DioException catch (e) {
      print('❌ createParcoursAcademique error status: ${e.response?.statusCode}');
      print('❌ createParcoursAcademique error body: ${e.response?.data}');
      throw Exception(e.response?.data ?? 'Erreur création parcours académique');
    }
  }

  Future<Map<String, dynamic>> updateParcoursAcademique(int id, Map<String, dynamic> data) async {
    final url = ApiConstants.parcoursAcademiquesUpdate.replaceFirst('{id}', '$id');
    try {
      final resp = await _dio.put(url, data: data);
      return resp.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Erreur mise à jour parcours académique');
    }
  }

  Future<Map<String, dynamic>> partialUpdateParcoursAcademique(int id, Map<String, dynamic> data) async {
    final url = ApiConstants.parcoursAcademiquesPartial.replaceFirst('{id}', '$id');
    try {
      final resp = await _dio.patch(url, data: data);
      return resp.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Erreur modification partielle parcours académique');
    }
  }

  Future<void> deleteParcoursAcademique(int id) async {
    final url = ApiConstants.parcoursAcademiquesDelete.replaceFirst('{id}', '$id');
    try {
      await _dio.delete(url);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Erreur suppression parcours académique');
    }
  }

  // -- Professionnel --

  Future<List<Map<String, dynamic>>> getParcoursProfessionnels() async {
    try {
      final resp = await _dio.get(ApiConstants.parcoursProfessionnelsList);
      return List<Map<String, dynamic>>.from(resp.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Erreur chargement parcours professionnels');
    }
  }

  Future<Map<String, dynamic>> getParcoursProfessionnel(int id) async {
    final url = ApiConstants.parcoursProfessionnelsRead.replaceFirst('{id}', '$id');
    try {
      final resp = await _dio.get(url);
      return Map<String, dynamic>.from(resp.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Erreur lecture parcours professionnel');
    }
  }

  Future<Map<String, dynamic>> createParcoursProfessionnel(Map<String, dynamic> data) async {
    print('📤 createParcoursProfessionnel payload: $data');
    try {
      final resp = await _dio.post(
        ApiConstants.parcoursProfessionnelsCreate,
        data: data,
        options: Options(
          contentType: Headers.jsonContentType, // assure JSON utf-8
        ),
      );
      print('✅ createParcoursProfessionnel response: ${resp.data}');
      return resp.data;
    } on DioException catch (e) {
      print('❌ createParcoursProfessionnel error status: ${e.response?.statusCode}');
      print('❌ createParcoursProfessionnel error body: ${e.response?.data}');
      throw Exception(e.response?.data ?? 'Erreur création parcours professionnel');
    }
  }
  Future<Map<String, dynamic>> updateParcoursProfessionnel(int id, Map<String, dynamic> data) async {
    final url = ApiConstants.parcoursProfessionnelsUpdate.replaceFirst('{id}', '$id');
    try {
      final resp = await _dio.put(url, data: data);
      return resp.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Erreur mise à jour parcours professionnel');
    }
  }

  Future<Map<String, dynamic>> partialUpdateParcoursProfessionnel(int id, Map<String, dynamic> data) async {
    final url = ApiConstants.parcoursProfessionnelsPartial.replaceFirst('{id}', '$id');
    try {
      final resp = await _dio.patch(url, data: data);
      return resp.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Erreur modification partielle parcours professionnel');
    }
  }

  Future<void> deleteParcoursProfessionnel(int id) async {
    final url = ApiConstants.parcoursProfessionnelsDelete.replaceFirst('{id}', '$id');
    try {
      await _dio.delete(url);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Erreur suppression parcours professionnel');
    }
  }
}

import 'package:dio/dio.dart';
import '../models/filiere_model.dart';
import '../constants/api_constants.dart';
import 'package:memoire/services/dio_client.dart';

class FiliereService {
  Future<List<FiliereModel>> fetchFilieres() async {
    try {
      final response = await DioClient.dio.get(ApiConstants.filieres);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => FiliereModel.fromJson(json)).toList();
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }

    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Erreur réseau lors de la récupération des filières';
      throw Exception(msg);
    }
  }
}

import 'package:dio/dio.dart';
import '../models/filiere_model.dart';
import '../constants/api_constants.dart';
import 'package:memoire/services/dio_client.dart';

class FiliereService {
  Future<List<FiliereModel>> fetchFilieres() async {
    print('🔍 FiliereService: Tentative de récupération des filières...');
    print('📍 URL: ${ApiConstants.filieres}');
    
    try {
      print('📡 Envoi de la requête GET...');
      final response = await DioClient.dio.get(ApiConstants.filieres);

      print('✅ Réponse reçue - Status: ${response.statusCode}');
      print('📦 Données reçues: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final filieres = data.map((json) => FiliereModel.fromJson(json)).toList();
        print('🎯 ${filieres.length} filières chargées avec succès');
        return filieres;
      } else {
        print('❌ Erreur serveur: ${response.statusCode}');
        throw Exception('Erreur serveur: ${response.statusCode}');
      }

    } on DioException catch (e) {
      print('🚨 Erreur DioException détectée:');
      print('   Type: ${e.type}');
      print('   Message: ${e.message}');
      print('   Status Code: ${e.response?.statusCode}');
      print('   Response Data: ${e.response?.data}');
      print('   Request URL: ${e.requestOptions.uri}');
      
      String errorMessage;
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Timeout de connexion - Vérifiez que le serveur est accessible';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Erreur de connexion - Impossible de joindre le serveur';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'Endpoint des filières non trouvé';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Erreur interne du serveur';
      } else {
        errorMessage = e.response?.data?['detail'] ?? 'Erreur réseau lors de la récupération des filières';
      }
      
      print('💡 Message d\'erreur final: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      print('🚨 Erreur inattendue: $e');
      throw Exception('Erreur inattendue: $e');
    }
  }
}

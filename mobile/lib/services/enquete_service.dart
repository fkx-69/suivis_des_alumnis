import 'package:memoire/constants/api_constants.dart';
import 'package:memoire/models/reponse_enquete_model.dart';
import 'package:memoire/services/dio_client.dart';
import 'package:dio/dio.dart';

class EnqueteService {
  static final EnqueteService _instance = EnqueteService._internal();

  factory EnqueteService() => _instance;

  EnqueteService._internal();

  Future<void> submitReponseEnquete(ReponseEnqueteModel reponse) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.repondreEnquete,
        data: reponse.toJson(),
      );

      if (response.statusCode != 201) {
        throw Exception("Erreur inattendue (${response.statusCode})");
      }
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      final erreurs = e.response?.data['errors'];
      String message = 'Erreur lors de l\'envoi';

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

import 'package:dio/dio.dart';
import 'package:memoire/constants/api_constants.dart';
import 'package:memoire/models/stat_domaine_model.dart';
import 'package:memoire/models/stat_situation_model.dart';
import 'dio_client.dart';

class StatistiqueService {
  final Dio _dio = DioClient.dio;

  Future<List<StatDomaineModel>> fetchDomainesParFiliere(int filiereId) async {
    final response = await _dio.get('${ApiConstants.statDomaines}/$filiereId/');
    final List<dynamic> data = response.data;
    return data.map((json) => StatDomaineModel.fromJson(json)).toList();
  }

  Future<List<StatSituationModel>> fetchSituationGenerale() async {
    final response = await _dio.get(ApiConstants.statSituation);
    final List<dynamic> data = response.data;
    return data.map((json) => StatSituationModel.fromJson(json)).toList();
  }
}

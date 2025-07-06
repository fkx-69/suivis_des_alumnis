import 'package:memoire/constants/api_constants.dart';
import 'package:memoire/models/notification_model.dart';
import 'package:dio/dio.dart';
import 'package:memoire/services/dio_client.dart';

class NotificationService {
  final Dio _dio = DioClient.dio;

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.notifications);
      print('Notifications JSON: ${response.data}');
      final List<dynamic> data = response.data;
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    } on DioException catch (e) {
      // Gère le cas où le backend renvoie 404 s'il n'y a pas de notifications
      if (e.response?.statusCode == 404) {
        return []; // Retourne une liste vide, ce qui est un état valide
      }
      // Pour les autres erreurs, on propage l'exception
      rethrow;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    await _dio.post(
      ApiConstants.notificationMarkRead.replaceFirst('{id}', notificationId.toString()),
    );
  }

  Future<void> deleteNotification(int notificationId) async {
    await _dio.delete(
      ApiConstants.notificationDelete.replaceFirst('{id}', notificationId.toString()),
    );
  }

}


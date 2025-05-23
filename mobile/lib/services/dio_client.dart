import 'package:dio/dio.dart';
import '../helpers/token_manager.dart';
import 'package:memoire/constants/api_constants.dart';

class DioClient {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl, // défini dans api_constants.dart
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
    },
  ))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await TokenManager.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Tu peux gérer ici le rafraîchissement du token plus tard
          // ou une déconnexion automatique
          print('⛔️ Unauthorized: Token expiré ?');
        }
        return handler.next(error);
      },
    ));

  // Méthode utilitaire si tu veux changer dynamiquement le token
  static void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearToken() {
    dio.options.headers.remove('Authorization');
  }
}

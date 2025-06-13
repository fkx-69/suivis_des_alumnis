import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import 'package:memoire/helpers/token_manager.dart';

class DioClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  )
  // 1) Notre intercepteur principal
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print("→ REQUEST ► ${options.method} ${options.uri}");
          print("   Headers: ${options.headers}");
          print("   Body   : ${options.data}");
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print("← RESPONSE ◀ ${response.statusCode} ${response.requestOptions.uri}");
          print("   Data: ${response.data}");
          return handler.next(response);
        },
        onError: (DioError error, handler) {
          print("⚠️ ERROR ◀ ${error.response?.statusCode} ${error.requestOptions.uri}");
          print("   ${error.response?.data}");
          return handler.next(error);
        },
      ),
    )
  // 2) Et un LogInterceptor complet pour tout tracer
    ..interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) => print(obj),
      ),
    );

  static void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearToken() {
    dio.options.headers.remove('Authorization');
  }
}

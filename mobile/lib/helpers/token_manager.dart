// lib/services/token_manager.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:memoire/services/dio_client.dart';

class TokenManager {
  static const _accessKey = 'access';
  static const _refreshKey = 'refresh';

  /// Sauvegarde l’access et le refresh token, puis injecte l’access token dans DioClient.
  static Future<void> saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    await prefs.setString(_refreshKey, refresh);
    DioClient.setToken(access);
  }

  /// Récupère l’access token stocké ou null si absent.
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  /// Récupère le refresh token (au cas où vous en aurez besoin).
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  /// Supprime les tokens et nettoie le header Authorization.
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    DioClient.clearToken();
  }
}

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:memoire/constants/api_constants.dart';
import 'package:memoire/models/alumni_model.dart';
import 'package:memoire/models/student_model.dart';
import 'package:memoire/models/user_model.dart';
import 'package:memoire/services/dio_client.dart';
import '../helpers/token_manager.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

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

        // On charge immédiatement les infos utilisateur
        await getUserInfo();

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
    _currentUser = null;
  }

  Future<Map<String, dynamic>> registerEtudiant(StudentModel etudiant) async {
    try {
      final response = await DioClient.dio.post(
        ApiConstants.registerEtudiant,
        data: etudiant.toJson(),
      );

      if (response.statusCode == 201) {
        // Optionnel : récupérer aussi l'utilisateur auto-connecté
        await getUserInfo();
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
        message =
            erreurs.entries.map((e) => '${e.key}: ${e.value}').join('\n');
      } else if (e.response?.data is Map &&
          e.response!.data.values.isNotEmpty) {
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

      if (response.statusCode == 201) {
        await getUserInfo();
        return response.data;
      }
      throw Exception('Échec de l\'inscription: ${response.data}');
    } on DioException catch (e) {
      final detail = e.response?.data['detail'];
      final erreurs = e.response?.data['errors'];
      String message = 'Erreur d\'inscription';

      if (detail != null) {
        message = detail.toString();
      } else if (erreurs is Map) {
        message =
            erreurs.entries.map((e) => '${e.key}: ${e.value}').join('\n');
      } else if (e.response?.data is Map &&
          e.response!.data.values.isNotEmpty) {
        message = e.response!.data.values.first.toString();
      }

      throw Exception(message);
    }
  }

  /// 🔐 Récupère les infos de l’utilisateur connecté (/api/accounts/me/)
  Future<UserModel> getUserInfo() async {
    try {
      final response = await DioClient.dio.get(ApiConstants.userInfo);
      if (response.statusCode == 200) {
        _currentUser = UserModel.fromJson(response.data);
        return _currentUser!;
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data['detail'] ?? 'Erreur de récupération utilisateur';
      throw Exception(message.toString());
    }
  }

  Future<UserModel> updateProfile({
    required String prenom,
    required String nom,
    required String username,
    String? biographie,
    File? photo,
  }) async {
    try {
      final formData = FormData.fromMap({
        'prenom': prenom,
        'nom': nom,
        'username': username,
        if (biographie != null) 'biographie': biographie,
        if (photo != null)
          'photo': await MultipartFile.fromFile(
            photo.path,
            filename: photo.path.split(Platform.pathSeparator).last,
          ),
      });

      final response = await DioClient.dio.put(
        ApiConstants.userUpdate,
        data: formData,
      );

      if (response.statusCode == 200) {
        _currentUser = UserModel.fromJson(response.data);
        return _currentUser!;
      } else {
        throw Exception('Erreur ${response.statusCode}');
      }
    } on DioException catch (e) {
      final message =
          e.response?.data['detail'] ?? 'Erreur de mise à jour du profil';
      throw Exception(message.toString());
    }
  }

  /// Récupère le profil public (ne nécessite pas de token).
  Future<UserModel> fetchPublicProfile(String username) async {
    final url = ApiConstants.accountRead.replaceFirst('{username}', username);
    print('✅ URL demandée : $url'); // AJOUT TEMPORAIRE
    final resp = await DioClient.dio.get(url);
    return UserModel.fromJson(resp.data as Map<String, dynamic>);
  }



  /// Envoie un message à un utilisateur ou à une conversation.
  Future<void> sendMessage({
    required String toUsername,
    required String contenu,
  }) async {
    await DioClient.dio.post(
      ApiConstants.messagingSend,
      data: {
        'to_username': toUsername,
        'contenu': contenu,
      },
    );
  }

  /// Envoie une demande de mentorat à un alumni.
  Future<void> sendMentorshipRequest({
    required int userId,
    String? message,
  }) async {
    await DioClient.dio.post(
      ApiConstants.mentoratSend,
      data: {
        'alumni_id': userId,
        if (message != null) 'message': message,
      },
    );
  }

  /// Signaler un utilisateur
  Future<void> reportUser({
    required int reportedUserId,
    required String reason,
  }) async {
    final data = {
      'reported_user_id': reportedUserId,
      'reason': reason,
    };

    print('SIGNALE UTILISATEUR - ENVOI: $data');

    try {
      final response = await DioClient.dio.post(
        ApiConstants.reportsReport,
        data: data,
      );
      print('SIGNALE UTILISATEUR - SUCCÈS: ${response.statusCode}');
    } on DioException catch (e) {
      print('SIGNALE UTILISATEUR - ERREUR DIO: ${e.response?.statusCode}');
      print('SIGNALE UTILISATEUR - ERREUR DATA: ${e.response?.data}');
      
      final errorMessage = e.response?.data?['detail'] ?? 
                           e.response?.data?.toString() ?? 
                           'Une erreur inconnue est survenue lors du signalement.';
      throw Exception(errorMessage);
    } catch (e) {
      print('SIGNALE UTILISATEUR - ERREUR INCONNUE: $e');
      throw Exception('Une erreur inattendue est survenue.');
    }
  }
  /// récupère la liste brute de tous les alumnis (JSON)
  Future<List<Map<String, dynamic>>> fetchAllAlumniJson() async {
    final resp = await DioClient.dio.get(ApiConstants.alumnisList);
    return List<Map<String, dynamic>>.from(resp.data as List);
  }



  /// Pipeline : username → alumni complet + user_id
  Future<Map<String, dynamic>> fetchPublicAlumniByUsername(String username) async {
    // 1) Liste brute de tous les alumnis
    final all = await fetchAllAlumniJson(); // List<Map>

    // 2) Trouve l’alumni via username
    final match = all.firstWhere(
          (a) => (a['user']?['username'] as String?)?.toLowerCase() == username.toLowerCase(),
      orElse: () => throw Exception('Aucun alumni trouvé pour "$username"'),
    );

    final user = match['user'] as Map<String, dynamic>?;
    if (user == null || user['id'] == null) {
      throw Exception('alumni user.id manquant pour $username');
    }

    final userId = user['id'];
    final alumniId = match['id'] ?? userId;

    // 3) On récupère les parcours depuis le backend
    final parcoursAcad = await fetchParcoursAcademiques(alumniId);
    final parcoursPro = await fetchParcoursProfessionnels(alumniId);

    // 4) On enrichit l’objet avec tous les éléments nécessaires
    match['user_id'] = userId;
    match['parcours_academiques'] = parcoursAcad;
    match['parcours_professionnels'] = parcoursPro;

    return match;
  }

  // ❌ Supprime ou commente cette méthode, devenue inutile
  // Future<Map<String, dynamic>> fetchPublicAlumniProfileById(int alumniId) async {
  //   final url = ApiConstants.publicAlumniProfileById
  //       .replaceFirst('{id}', alumniId.toString());
  //   final resp = await DioClient.dio.get(url);
  //   return Map<String, dynamic>.from(resp.data as Map);
  // }

  /// Récupère les parcours académiques d’un alumni par son ID
  Future<List<Map<String, dynamic>>> fetchParcoursAcademiques(int alumniId) async {
    try {
      final url = '${ApiConstants.parcoursAcademiquesAlumni}$alumniId/';
      final response = await DioClient.dio.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Erreur chargement parcours académiques');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Erreur chargement parcours académiques';
      throw Exception(msg.toString());
    }
  }

  /// Récupère les parcours professionnels d’un alumni par son ID
  Future<List<Map<String, dynamic>>> fetchParcoursProfessionnels(int alumniId) async {
    try {
      final url = '${ApiConstants.parcoursProfessionnelsAlumni}$alumniId/';
      final response = await DioClient.dio.get(url);
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      } else {
        throw Exception('Erreur chargement parcours professionnels');
      }
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Erreur chargement parcours professionnels';
      throw Exception(msg.toString());
    }
  }
  /// Récupère le username de l'utilisateur connecté
  String? getCurrentUsername() {
    return _currentUser?.username;
  }

}

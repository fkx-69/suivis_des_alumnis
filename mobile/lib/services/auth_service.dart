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

  Future<UserModel> fetchPublicProfile(String username) async {
    final url = ApiConstants.accountRead.replaceFirst('{username}', username);
    print('✅ fetchPublicProfile URL → $url');
    final resp = await DioClient.dio.get(url);

    // NOUVEAU : logguez la réponse brute
    print('✅ fetchPublicProfile RAW → ${resp.data}');

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
  ///  Future<void> sendMentorshipRequest({
  ///  required int userId,
///   String? message,
  ///  }) async {
  ///   await DioClient.dio.post(ApiConstants.mentoratSend,
  /// data: {'alumni_id': userId,
///  if (message != null) 'message': message,},);}

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
  /// récupère la liste des alumnis (JSON), avec possibilité de recherche par username
  Future<List<Map<String, dynamic>>> fetchAllAlumniJson({String? username}) async {
    final params = <String, dynamic>{};
    if (username != null && username.isNotEmpty) {
      // On assume que le backend supporte la recherche via un paramètre 'search'
      params['search'] = username;
    }
    final resp = await DioClient.dio.get(ApiConstants.alumnisList, queryParameters: params);

    // Gère une réponse paginée de DRF, qui est un Map contenant 'results'
    if (resp.data is Map<String, dynamic> && resp.data.containsKey('results')) {
      return List<Map<String, dynamic>>.from(resp.data['results'] as List);
    }
    // Gère une réponse non paginée, qui est directement une List
    return List<Map<String, dynamic>>.from(resp.data as List);
  }



  /// Pipeline : username → alumni complet + user_id
  Future<Map<String, dynamic>> fetchPublicAlumniByUsername(String username) async {
    // Étape 1 : Récupérer le profil utilisateur de base pour obtenir son ID.
    final userProfile = await fetchPublicProfile(username);
    final userId = userProfile.id;

    // Étape 2 : Utiliser l'endpoint de profil détaillé en pariant qu'il accepte un USER_ID.
    final url = ApiConstants.publicAlumniProfileById.replaceFirst('{id}', userId.toString());
    final resp = await DioClient.dio.get(url);
    final alumniData = resp.data as Map<String, dynamic>;

    // Étape 3 : Vérifier si l'ID de l'objet Alumni est maintenant présent.
    final alumniId = alumniData['id'] as int?;
    if (alumniId == null) {
      throw Exception(
          "La solution de contournement a échoué. L'ID de l'alumni est toujours manquant, même sur l'endpoint de profil détaillé. Un changement au backend est requis pour inclure le champ 'id' dans la réponse de l'API.");
    }

    // Étape 4 : Utiliser l'ID d'alumni pour récupérer les parcours.
    final parcoursAcad = await fetchParcoursAcademiques(alumniId);
    final parcoursPro = await fetchParcoursProfessionnels(alumniId);

    // Étape 5 : Enrichir l'objet avec les parcours et le retourner.
    alumniData['parcours_academiques'] = parcoursAcad;
    alumniData['parcours_professionnels'] = parcoursPro;

    return alumniData;
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

  /// LA NOUVELLE FONCTION ROBUSTE
  /// Charge le profil complet d'un alumni (infos user + parcours) en une seule fois.
  /// C'est la méthode à privilégier pour l'écran de profil public.
  Future<Map<String, dynamic>> fetchCompleteAlumniProfile(String username) async {
    // 1. Rechercher l'alumni dans la liste pour obtenir les IDs et les données complètes.
    final results = await fetchAllAlumniJson(username: username);

    if (results.isEmpty) {
      throw Exception('Aucun alumni trouvé pour "$username".');
    }

    final match = results.firstWhere(
      (a) => (a['user']?['username'] as String?)?.toLowerCase() == username.toLowerCase(),
      orElse: () => throw Exception('Aucune correspondance exacte pour "$username".'),
    );

    // 2. Extraire l'objet utilisateur complet et l'ID de l'alumni.
    final userObject = match['user'] as Map<String, dynamic>?;
    final alumniId = match['id'] as int?;

    if (userObject == null || userObject['id'] == null || alumniId == null) {
      throw Exception(
          "L'API ne retourne pas les données complètes. L'ID utilisateur ou l'ID alumni est manquant.");
    }

    // 3. Créer le modèle UserModel complet.
    final userModel = UserModel.fromJson(userObject);

    // 4. Récupérer les parcours.
    final parcoursAcad = await fetchParcoursAcademiques(alumniId);
    final parcoursPro = await fetchParcoursProfessionnels(alumniId);

    // 5. Retourner toutes les données nécessaires pour l'écran de profil.
    return {
      'user': userModel,
      'parcours_academiques': parcoursAcad,
      'parcours_professionnels': parcoursPro,
    };
  }
}

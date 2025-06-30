// lib/services/groupe_service.dart

import 'package:dio/dio.dart';
import 'package:memoire/constants/api_constants.dart';
import 'package:memoire/models/group_model.dart';
import 'package:memoire/services/dio_client.dart';

class GroupeService {
  final Dio _dio = DioClient.dio;

  /// Récupère tous les groupes (avec isMember)
  Future<List<GroupModel>> fetchGroups() async {
    try {
      final resp = await _dio.get(ApiConstants.groupsList);
      return (resp.data as List<dynamic>)
          .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Erreur chargement groupes');
    }
  }

  /// Récupère uniquement les groupes rejoints
  Future<List<GroupModel>> fetchMyGroups() async {
    try {
      final resp = await _dio.get(ApiConstants.myGroupsList);
      return (resp.data as List<dynamic>)
          .map((e) => GroupModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException {
      throw Exception('Erreur chargement mes groupes');
    }
  }

  /// Créer un groupe
  Future<GroupModel> createGroup({
    required String nomGroupe,
    required String description,
  }) async {
    final resp = await _dio.post(
      ApiConstants.groupsCreate,
      data: {'nom_groupe': nomGroupe, 'description': description},
    );
    return GroupModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Rejoindre un groupe
  Future<void> joinGroup(int id) async {
    final url = ApiConstants.groupsJoin.replaceFirst('{groupe_id}', '$id');
    await _dio.post(url);
  }

  /// Quitter un groupe
  Future<void> quitGroup(int id) async {
    final url = ApiConstants.groupsQuit.replaceFirst('{groupe_id}', '$id');
    await _dio.post(url);
  }

  Future<List<GroupMemberModel>> fetchMembers(int id) async {
    final url  = ApiConstants.groupsMembers.replaceFirst('{groupe_id}', '$id');
    final resp = await _dio.get(url);

    // Récupère soit resp.data['membres'], soit resp.data
    final raw = (resp.data is Map && resp.data['membres'] != null)
        ? resp.data['membres']
        : resp.data;

    final List list = raw as List;

    return list.map((e) {
      if (e is String) {
        // Cas où l'API renvoie juste un username
        return GroupMemberModel(
          id: 0,
          username: e,
          nom: null,
          prenom: null,
          role: null,
        );
      } else if (e is Map<String, dynamic>) {
        return GroupMemberModel.fromJson(e);
      } else {
        throw Exception('Type de membre inattendu: ${e.runtimeType}');
      }
    }).toList();
  }


  /// Récupérer les messages
  Future<List<GroupMessageModel>> fetchMessages(int id) async {
    final url = ApiConstants.groupsMessages.replaceFirst('{groupe_id}', '$id');
    final resp = await _dio.get(url);
    return (resp.data as List<dynamic>)
        .map((e) => GroupMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Envoyer un message
  Future<GroupMessageModel> sendMessage({
    required int id,
    required String contenu,
  }) async {
    final url =
    ApiConstants.groupsSendMessage.replaceFirst('{groupe_id}', '$id');
    final resp = await _dio.post(url, data: {'contenu': contenu});
    return GroupMessageModel.fromJson(resp.data as Map<String, dynamic>);
  }
}

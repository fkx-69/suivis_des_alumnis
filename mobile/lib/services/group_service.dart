// lib/services/groupe_service.dart

import 'package:dio/dio.dart';
import 'package:memoire/constants/api_constants.dart';
import 'package:memoire/models/group_model.dart';
import 'package:memoire/services/auth_service.dart';

class GroupeService {
  final Dio _dio = Dio();

  /// Récupère la liste de tous les groupes
  Future<List<GroupModel>> getAllGroups() async {
    final resp = await _dio.get(ApiConstants.groupsList);
    final List data = resp.data as List;
    return data.map((j) => GroupModel.fromJson(j)).toList();
  }

  /// Crée un nouveau groupe et retourne le modèle créé.
  Future<GroupModel> createGroup({
    required String nomGroupe,
    required String description,
  }) async {
    final resp = await _dio.post(
      ApiConstants.groupsCreate,
      data: {
        'nom_groupe': nomGroupe,
        'description': description,
      },
    );
    return GroupModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Rejoint un groupe
  Future<void> joinGroup(int groupeId) async {
    final url = ApiConstants.groupsJoin.replaceFirst('{groupe_id}', groupeId.toString());
    await _dio.post(url);
  }

  /// Quitte un groupe
  Future<void> quitGroup(int groupeId) async {
    final url = ApiConstants.groupsQuit.replaceFirst('{groupe_id}', groupeId.toString());
    await _dio.post(url);
  }

  /// Récupère la liste des membres d’un groupe
  Future<List<GroupMemberModel>> getMembers(int groupeId) async {
    final url = ApiConstants.groupsMembers.replaceFirst('{groupe_id}', groupeId.toString());
    final resp = await _dio.get(url);
    final List data = resp.data as List;
    return data
        .map((j) => GroupMemberModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Récupère la liste des messages d’un groupe
  Future<List<GroupMessageModel>> getMessages(int groupeId) async {
    final url = ApiConstants.groupsMessages.replaceFirst('{groupe_id}', groupeId.toString());
    final resp = await _dio.get(url);
    final List data = resp.data as List;
    return data
        .map((j) => GroupMessageModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Envoie un message dans un groupe
  Future<GroupMessageModel> sendMessage({
    required int groupeId,
    required String contenu,
  }) async {
    final url = ApiConstants.groupsSendMessage.replaceFirst('{groupe_id}', groupeId.toString());
    final resp = await _dio.post(
      url,
      data: {'message': contenu},
    );
    return GroupMessageModel.fromJson(resp.data as Map<String, dynamic>);
  }
}

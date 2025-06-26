// lib/services/groupe_service.dart
import 'package:memoire/constants/api_constants.dart';
import 'package:memoire/models/group_model.dart';
import 'package:memoire/services/dio_client.dart';

class GroupeService {
  final _dio = DioClient.dio; // Utilise ton singleton DioClient avec JWT

  Future<List<GroupModel>> fetchGroups() async {
    final resp = await _dio.get(ApiConstants.groupsList);
    final List data = resp.data as List;
    return data.map((e) => GroupModel.fromJson(e)).toList();
  }

  Future<GroupModel> createGroup({
    required String nomGroupe,
    required String description,
  }) async {
    final resp = await _dio.post(ApiConstants.groupsCreate, data: {
      'nom_groupe': nomGroupe,
      'description': description,
    });
    return GroupModel.fromJson(resp.data);
  }

  Future<void> joinGroup(int id) async {
    final url = ApiConstants.groupsJoin.replaceFirst('{groupe_id}', '$id');
    await _dio.post(url);
  }

  Future<void> quitGroup(int id) async {
    final url = ApiConstants.groupsQuit.replaceFirst('{groupe_id}', '$id');
    await _dio.post(url);
  }

  Future<List<GroupMemberModel>> fetchMembers(int id) async {
    final url = ApiConstants.groupsMembers.replaceFirst('{groupe_id}', '$id');
    final resp = await _dio.get(url);
    final List data = resp.data['membres'] ?? resp.data as List;
    return data.map((e) => GroupMemberModel.fromJson(e)).toList();
  }

  Future<List<GroupMessageModel>> fetchMessages(int id) async {
    final url = ApiConstants.groupsMessages.replaceFirst('{groupe_id}', '$id');
    final resp = await _dio.get(url);
    final List data = resp.data as List;
    return data.map((e) => GroupMessageModel.fromJson(e)).toList();
  }

  Future<GroupMessageModel> sendMessage({
    required int id,
    required String contenu,
  }) async {
    final url = ApiConstants.groupsSendMessage.replaceFirst('{groupe_id}', '$id');
    final resp = await _dio.post(url, data: {'contenu': contenu});
    return GroupMessageModel.fromJson(resp.data);
  }
}

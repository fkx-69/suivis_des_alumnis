import 'package:dio/dio.dart';
import 'package:memoire/constants/api_constants.dart';
import 'package:memoire/models/conversation_model.dart';
import 'package:memoire/models/private_message_model.dart';
import 'package:memoire/services/dio_client.dart';

class MessagingService {
  final Dio _dio = DioClient.dio;

  /// Liste des conversations (résumés)
  Future<List<ConversationModel>> fetchConversations() async {
    final resp = await _dio.get(ApiConstants.messagingConversations);
    return (resp.data as List)
        .map((e) => ConversationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Envoi d'un message privé
  Future<PrivateMessageModel> sendMessage({
    required String toUsername,
    required String contenu,
  }) async {
    final resp = await _dio.post(
      ApiConstants.messagingSend,
      data: {
        'to_username': toUsername,
        'contenu': contenu,
      },
    );
    return PrivateMessageModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Messages envoyés
  Future<List<PrivateMessageModel>> fetchSent() async {
    final resp = await _dio.get(ApiConstants.messagingSent);
    return (resp.data as List)
        .map((e) => PrivateMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Messages reçus
  Future<List<PrivateMessageModel>> fetchReceived() async {
    final resp = await _dio.get(ApiConstants.messagingReceived);
    return (resp.data as List)
        .map((e) => PrivateMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Conversation privée avec un utilisateur
  Future<List<PrivateMessageModel>> fetchWith(String username) async {
    final url = ApiConstants.messagingWithUser.replaceFirst('{username}', username);
    final resp = await _dio.get(url);
    return (resp.data as List)
        .map((e) => PrivateMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
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
}

import 'package:dio/dio.dart';
import 'package:memoire/constants/api_constants.dart';
import 'package:memoire/models/conversation_model.dart';
import 'package:memoire/models/private_message_model.dart';
import 'package:memoire/models/mentorship_request_model.dart';
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
  Future<void> sendMessage({
    required String toUsername,
    required String contenu,
  }) async {
    await _dio.post(
      ApiConstants.messagingSend,
      data: {
        'destinataire_username': toUsername,
        'contenu': contenu,
      },
    );
    // Pas de traitement de la réponse pour plus de robustesse.
    // L'UI se met à jour en rechargeant la conversation.
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
  /// Envoie une demande de mentorat à un alumni en utilisant son nom d'utilisateur.
  Future<void> sendMentorshipRequest({
    required String username,
    String? message,
  }) async {
    // Conformément à l'implémentation web, nous utilisons le 'username'.
    // La clé 'destinataire_username' est choisie par cohérence avec l'envoi de messages privés.
    await DioClient.dio.post(
      ApiConstants.mentoratSend,
      data: {
        'destinataire_username': username,
        'message': message ?? '',
      },
    );
  }

  /// Récupère les demandes de mentorat (reçues et envoyées).
  Future<List<MentorshipRequestModel>> fetchMyMentorshipRequests() async {
    final response = await _dio.get(ApiConstants.mentoratMyRequests);
    final data = response.data as List;
    return data
        .map((item) => MentorshipRequestModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Accepte ou refuse une demande de mentorat.
  Future<void> respondToMentorshipRequest({
    required int requestId,
    required String status, // 'acceptee' or 'refusee'
    String? reason,
  }) async {
    final url = ApiConstants.mentoratRespond.replaceFirst('{id}', requestId.toString());
    await _dio.patch(
      url,
      data: {
        'statut': status,
        if (reason != null) 'reason': reason,
      },
    );
  }

  /// Met à jour le message d'une demande de mentorat.
  Future<void> updateMentorshipRequestMessage({
    required int requestId,
    required String message,
  }) async {
    final url = ApiConstants.mentoratRespond.replaceFirst('{id}', requestId.toString());
    await _dio.put(
      url,
      data: {'message': message},
    );
  }

  /// Supprime une demande de mentorat envoyée.
  Future<void> deleteMentorshipRequest({required int requestId}) async {
    final url = ApiConstants.mentoratDelete.replaceFirst('{id}', requestId.toString());
    await _dio.delete(url);
  }
}

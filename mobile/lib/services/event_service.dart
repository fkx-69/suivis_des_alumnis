// lib/services/event_service.dart

import 'package:dio/dio.dart';
import '../models/event_model.dart';
import '../constants/api_constants.dart';
import 'dio_client.dart';

class EventService {
  final Dio _dio = DioClient.dio;

  /// Récupère la liste de tous les événements du calendrier (GET /events/calendrier/).
  Future<List<EventModel>> fetchCalendar() async {
    final resp = await _dio.get(ApiConstants.eventsCalendar);
    final List data = resp.data as List;
    return data
        .map((j) => EventModel.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  /// Crée un nouvel événement (POST /events/creer/).
  Future<EventModel> createEvent(EventModel event) async {
    final payload = event.toJson();
    print("→ Payload création d’événement : $payload");

    final resp = await _dio.post(
      ApiConstants.eventsCreate,
      data: payload,
    );
    return EventModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Supprime un événement (DELETE /events/evenements/{id}/supprimer/).
  Future<void> deleteEvent(int id) async {
    final url = ApiConstants.eventsDelete.replaceFirst('{id}', '$id');
    print("→ Suppression de l’événement id=$id → URL = $url");
    await _dio.delete(url);
  }

  /// Met à jour un événement en totalité (PUT /events/{id}/modifier/).
  Future<EventModel> updateEvent(int id, EventModel event) async {
    final url = ApiConstants.eventsUpdate.replaceFirst('{id}', '$id');
    final payload = event.toJson();
    print("→ Payload PUT (id=$id) : $payload");

    final resp = await _dio.put(
      url,
      data: payload,
    );
    return EventModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Met à jour partiellement un événement (PATCH /events/{id}/modifier/).
  Future<EventModel> partialUpdateEvent(int id, Map<String, dynamic> dataPatch) async {
    final url = ApiConstants.eventsPartial.replaceFirst('{id}', '$id');
    print("→ Payload PATCH (id=$id) : $dataPatch");

    final resp = await _dio.patch(
      url,
      data: dataPatch,
    );
    return EventModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Valide un événement (POST /events/{id}/valider/).
  Future<void> validateEvent(int id) async {
    final url = ApiConstants.eventsValidate.replaceFirst('{id}', '$id');
    print("→ Validation de l’événement id=$id → URL = $url");
    await _dio.post(url);
  }
}

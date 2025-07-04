import 'dart:io';
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
  Future<EventModel> createEvent(EventModel event, {File? image}) async {
    final Map<String, dynamic> eventData = event.toJson();
    final formData = FormData.fromMap(eventData);

    if (image != null) {
      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(image.path, filename: image.path.split('/').last),
      ));
    }

    final resp = await _dio.post(ApiConstants.eventsCreate, data: formData);
    return EventModel.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Valide un événement (POST /events/{id}/valider/).
  Future<void> validateEvent(int id) async {
    final url = ApiConstants.eventsValidate.replaceFirst('{id}', '$id');
    await _dio.post(url);
  }
  /// 🔹 Récupère la liste des événements créés par l'utilisateur
  Future<List<EventModel>> fetchMyEvents() async {
    final resp = await _dio.get(ApiConstants.myEvents);
    final List data = resp.data as List;
    return data.map((j) => EventModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  /// 🔹 Supprime un événement en attente
  Future<void> deleteEvent(int id) async {
    final url = ApiConstants.eventsDelete.replaceFirst('{id}', id.toString());
    await _dio.delete(url);
  }

  /// 🔹 Met à jour un événement existant
  Future<EventModel> updateEvent(int id, EventModel event, {File? image}) async {
    final url = ApiConstants.eventsUpdate.replaceFirst('{id}', id.toString());
    final Map<String, dynamic> eventData = event.toJson();

    final formData = FormData.fromMap({
      ...eventData,
      if (image != null)
        'image': await MultipartFile.fromFile(image.path, filename: image.path.split('/').last),
    });

    final resp = await _dio.put(url, data: formData);
    return EventModel.fromJson(resp.data as Map<String, dynamic>);
  }

}

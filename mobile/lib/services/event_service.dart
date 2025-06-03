import 'package:dio/dio.dart';
import '../models/event_model.dart';
import '../constants/api_constants.dart';
import 'dio_client.dart';

class EventService {
  final Dio _dio = DioClient.dio;

  /// Liste tous les événements du calendrier
  Future<List<EventModel>> fetchCalendar() async {
    final resp = await _dio.get(ApiConstants.eventsCalendar);
    return (resp.data as List)
        .map((j) => EventModel.fromJson(j))
        .toList();
  }

  /// Crée un nouvel événement
  Future<EventModel> createEvent(EventModel event) async {
    final resp = await _dio.post(
      ApiConstants.eventsCreate,
      data: event.toJson(),
    );
    return EventModel.fromJson(resp.data);
  }

  /// Mettre à jour un événement en PUT
  Future<EventModel> updateEvent(int id, EventModel event) async {
    final url = ApiConstants.eventsUpdate.replaceFirst('{id}', '$id');
    final resp = await _dio.put(url, data: event.toJson());
    return EventModel.fromJson(resp.data);
  }

  /// Mise à jour partielle en PATCH
  Future<EventModel> partialUpdateEvent(int id, Map<String, dynamic> data) async {
    final url = ApiConstants.eventsPartial.replaceFirst('{id}', '$id');
    final resp = await _dio.patch(url, data: data);
    return EventModel.fromJson(resp.data);
  }

  /// Valide un événement
  Future<void> validateEvent(int id) async {
    final url = ApiConstants.eventsValidate.replaceFirst('{id}', '$id');
    await _dio.post(url);
  }
}

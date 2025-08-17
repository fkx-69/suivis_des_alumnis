import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/api_constants.dart';
import '../helpers/token_manager.dart';
import '../models/event_model.dart';
import 'dio_client.dart';

class EventService {
  final Dio _dio = DioClient.dio;
  final ImagePicker _picker = ImagePicker();
  
  // Callback pour notifier quand un événement est créé
  static final List<Function(EventModel)> _eventCreatedCallbacks = [];
  
  // Méthode pour s'abonner aux événements créés
  static void onEventCreated(Function(EventModel) callback) {
    _eventCreatedCallbacks.add(callback);
  }
  
  // Méthode pour se désabonner
  static void removeEventCreatedCallback(Function(EventModel) callback) {
    _eventCreatedCallbacks.remove(callback);
  }
  
  // Méthode pour notifier tous les abonnés
  static void _notifyEventCreated(EventModel event) {
    for (final callback in _eventCreatedCallbacks) {
      try {
        callback(event);
      } catch (e) {
        print('Erreur dans le callback d\'événement créé: $e');
      }
    }
  }

  /// Récupère la liste de tous les événements du calendrier (GET /events/evenements/).
  Future<List<EventModel>> fetchCalendar() async {
    print("🔄 EventService: Tentative de récupération du calendrier...");
    final token = await TokenManager.getAccessToken();
    print("🔑 EventService: Token présent: ${token != null && token.isNotEmpty}");
    
    final resp = await _dio.get(ApiConstants.eventsCalendar);
    print("✅ EventService: Calendrier récupéré avec succès");
    
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
    final createdEvent = EventModel.fromJson(resp.data as Map<String, dynamic>);
    _notifyEventCreated(createdEvent); // Notify subscribers
    return createdEvent;
  }

  /// Valide un événement (POST /events/{id}/valider/).
  Future<void> validateEvent(int id) async {
    final url = ApiConstants.eventsValidate.replaceFirst('{id}', '$id');
    await _dio.post(url);
  }
  /// 🔹 Récupère la liste des événements créés par l'utilisateur
  Future<List<EventModel>> fetchMyEvents() async {
    print("🔄 EventService: Tentative de récupération de mes événements...");
    final token = await TokenManager.getAccessToken();
    print("🔑 EventService: Token présent pour mes événements: ${token != null && token.isNotEmpty}");
    
    final resp = await _dio.get(ApiConstants.myEvents);
    print("✅ EventService: Mes événements récupérés avec succès");
    
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

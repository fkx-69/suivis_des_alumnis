import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import 'event_service.dart';
import '../helpers/token_manager.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  
  List<EventModel> _allEvents = [];
  List<EventModel> _myEvents = [];
  bool _isLoading = false;
  
  List<EventModel> get allEvents => _allEvents;
  List<EventModel> get myEvents => _myEvents;
  bool get isLoading => _isLoading;
  
  // Événements à venir (validés et futurs)
  List<EventModel> get upcomingEvents {
    final now = DateTime.now();
    return _allEvents.where((event) => 
      event.valide && event.dateDebut.isAfter(now)
    ).toList();
  }
  
  // Événements à venir de l'utilisateur
  List<EventModel> get myUpcomingEvents {
    final now = DateTime.now();
    return _myEvents.where((event) => 
      event.dateDebut.isAfter(now)
    ).toList();
  }
  
  EventProvider() {
    // S'abonner aux événements créés
    EventService.onEventCreated(_onEventCreated);
  }
  
  @override
  void dispose() {
    EventService.removeEventCreatedCallback(_onEventCreated);
    super.dispose();
  }
  
  // Callback quand un nouvel événement est créé
  void _onEventCreated(EventModel newEvent) {
    // Ajouter aux listes appropriées
    _allEvents.insert(0, newEvent);
    _myEvents.insert(0, newEvent);
    notifyListeners();
    print("🎉 EventProvider: Nouvel événement ajouté: ${newEvent.titre}");
  }
  
  // Charger tous les événements
  Future<void> loadAllEvents() async {
    _setLoading(true);
    try {
      print("🔄 EventProvider: Chargement de tous les événements...");
      
      // Vérifier si l'utilisateur est connecté
      final token = await TokenManager.getAccessToken();
      if (token == null || token.isEmpty) {
        print("❌ EventProvider: Aucun token d'authentification trouvé");
        return;
      }
      
      _allEvents = await _eventService.fetchCalendar();
      print("✅ EventProvider: ${_allEvents.length} événements chargés");
      notifyListeners();
    } catch (e) {
      print("❌ EventProvider: Erreur lors du chargement des événements: $e");
      // En cas d'erreur, on garde les événements existants
    } finally {
      _setLoading(false);
    }
  }
  
  // Charger mes événements
  Future<void> loadMyEvents() async {
    try {
      print("🔄 EventProvider: Chargement de mes événements...");
      
      // Vérifier si l'utilisateur est connecté
      final token = await TokenManager.getAccessToken();
      if (token == null || token.isEmpty) {
        print("❌ EventProvider: Aucun token d'authentification trouvé pour mes événements");
        return;
      }
      
      _myEvents = await _eventService.fetchMyEvents();
      print("✅ EventProvider: ${_myEvents.length} de mes événements chargés");
      notifyListeners();
    } catch (e) {
      print("❌ EventProvider: Erreur lors du chargement de mes événements: $e");
      // En cas d'erreur, on garde les événements existants
    }
  }
  
  // Créer un événement
  Future<EventModel?> createEvent(EventModel event, {dynamic image}) async {
    try {
      final createdEvent = await _eventService.createEvent(event, image: image);
      // L'événement sera automatiquement ajouté via le callback
      return createdEvent;
    } catch (e) {
      print("Erreur lors de la création de l'événement: $e");
      return null;
    }
  }
  
  // Valider un événement
  Future<void> validateEvent(int eventId) async {
    try {
      print("🔄 EventProvider: Validation de l'événement $eventId...");
      await _eventService.validateEvent(eventId);
      
      // Mettre à jour le statut dans les listes
      final allIndex = _allEvents.indexWhere((e) => e.id == eventId);
      if (allIndex != -1) {
        _allEvents[allIndex] = _allEvents[allIndex].copyWith(valide: true);
      }
      
      final myIndex = _myEvents.indexWhere((e) => e.id == eventId);
      if (myIndex != -1) {
        _myEvents[myIndex] = _myEvents[myIndex].copyWith(valide: true);
      }
      
      notifyListeners();
      print("✅ EventProvider: Événement $eventId validé avec succès");
    } catch (e) {
      print("❌ EventProvider: Erreur lors de la validation de l'événement $eventId: $e");
      throw Exception('Erreur lors de la validation de l\'événement: $e');
    }
  }

  // Supprimer un événement
  Future<void> deleteEvent(int eventId) async {
    try {
      await _eventService.deleteEvent(eventId);
      // Retirer des listes
      _allEvents.removeWhere((e) => e.id == eventId);
      _myEvents.removeWhere((e) => e.id == eventId);
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la suppression de l'événement: $e");
    }
  }
  
  // Mettre à jour un événement
  Future<void> updateEvent(int id, EventModel event, {dynamic image}) async {
    try {
      final updatedEvent = await _eventService.updateEvent(id, event, image: image);
      // Mettre à jour dans les listes
      final allIndex = _allEvents.indexWhere((e) => e.id == id);
      if (allIndex != -1) {
        _allEvents[allIndex] = updatedEvent;
      }
      
      final myIndex = _myEvents.indexWhere((e) => e.id == id);
      if (myIndex != -1) {
        _myEvents[myIndex] = updatedEvent;
      }
      
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la mise à jour de l'événement: $e");
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Rafraîchir toutes les données
  Future<void> refresh() async {
    await Future.wait([
      loadAllEvents(),
      loadMyEvents(),
    ]);
  }
} 
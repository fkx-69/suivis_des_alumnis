// lib/models/event_model.dart

class EventModel {
  final int id;
  final String titre;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;

  // Champs en lecture seule (renvoyés par l’API, mais jamais envoyés)
  final String? dateDebutAffiche;
  final String? dateFinAffiche;
  final String? createur;

  EventModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
    this.dateDebutAffiche,
    this.dateFinAffiche,
    this.createur,
  });

  /// Construit un EventModel à partir du JSON renvoyé par l’API.
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      titre: json['titre'] as String,
      description: json['description'] as String,
      dateDebut: DateTime.parse(json['date_debut'] as String),
      dateFin: DateTime.parse(json['date_fin'] as String),
      dateDebutAffiche: json['date_debut_affiche'] as String?,
      dateFinAffiche: json['date_fin_affiche'] as String?,
      createur: json['createur'] as String?,
    );
  }

  /// Convertit l’EventModel en JSON pour l’envoi à l’API.
  /// N’inclut que les champs modifiables/corrects pour POST/PUT/PATCH.
  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      // NB : date_debut_affiche, date_fin_affiche et createur ne doivent pas être
      //      envoyés, ce sont des champs en lecture seule.
    };
  }
}

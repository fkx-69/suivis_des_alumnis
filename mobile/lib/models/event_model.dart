// lib/models/event_model.dart

class EventModel {
  final int id;
  final String titre;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String? image; // Champ pour l'URL de l'image
  final bool valide;

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
    this.image,
    this.valide = false,
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
      image: json['image'] as String?,
      valide: json['valide'] as bool? ?? false,
      dateDebutAffiche: json['date_debut_affiche'] as String?,
      dateFinAffiche: json['date_fin_affiche'] as String?,
      createur: json['createur'] as String?,
    );
  }

  /// Convertit l'EventModel en JSON pour l'envoi à l'API.
  /// N'inclut que les champs modifiables/corrects pour POST/PUT/PATCH.
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

  /// Crée une copie de l'EventModel avec des champs modifiés
  EventModel copyWith({
    int? id,
    String? titre,
    String? description,
    DateTime? dateDebut,
    DateTime? dateFin,
    String? image,
    bool? valide,
    String? dateDebutAffiche,
    String? dateFinAffiche,
    String? createur,
  }) {
    return EventModel(
      id: id ?? this.id,
      titre: titre ?? this.titre,
      description: description ?? this.description,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      image: image ?? this.image,
      valide: valide ?? this.valide,
      dateDebutAffiche: dateDebutAffiche ?? this.dateDebutAffiche,
      dateFinAffiche: dateFinAffiche ?? this.dateFinAffiche,
      createur: createur ?? this.createur,
    );
  }
}

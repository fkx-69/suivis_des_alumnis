// lib/models/event_model.dart

class EventModel {
  final int id;
  final String titre;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;
  // champs read-only
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

  factory EventModel.fromJson(Map<String, dynamic> json) {
    // on parse les dates si le backend les renvoie
    final deb = DateTime.parse(json['date_debut'] as String);
    final fin = DateTime.parse(json['date_fin']   as String);
    return EventModel(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      dateDebut: deb,
      dateFin: fin,
      dateDebutAffiche: json['date_debut_affiche'],
      dateFinAffiche: json['date_fin_affiche'],
      createur: json['createur'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin':   dateFin.toIso8601String(),
    };
  }
}

class EventModel {
  final int id;
  final String titre;
  final String description;
  final String? dateDebutAffiche;
  final String? dateFinAffiche;
  final String? createur;

  EventModel({
    required this.id,
    required this.titre,
    required this.description,
    this.dateDebutAffiche,
    this.dateFinAffiche,
    this.createur,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      dateDebutAffiche: json['date_debut_affiche'],
      dateFinAffiche: json['date_fin_affiche'],
      createur: json['createur'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titre': titre,
      'description': description,
    };
  }
}

class ReponseEnqueteModel {
  final bool aTrouveEmploi;
  final DateTime? dateDebutEmploi;
  final String domaine;
  final String? autreDomaine;
  final int noteInsertion;
  final String? suggestions;

  ReponseEnqueteModel({
    required this.aTrouveEmploi,
    this.dateDebutEmploi,
    required this.domaine,
    this.autreDomaine,
    required this.noteInsertion,
    this.suggestions,
  });

  Map<String, dynamic> toJson() {
    return {
      'a_trouve_emploi': aTrouveEmploi,
      'date_debut_emploi':
      dateDebutEmploi != null ? dateDebutEmploi!.toIso8601String() : null,
      'domaine': domaine,
      'autre_domaine': autreDomaine,
      'note_insertion': noteInsertion,
      'suggestions': suggestions,
    };
  }
}

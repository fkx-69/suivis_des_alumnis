class FiliereModel {
  final int id;
  final String code;
  final String nomComplet;

  FiliereModel({required this.id, required this.code, required this.nomComplet});

  factory FiliereModel.fromJson(Map<String, dynamic> json) {
    return FiliereModel(
      id: json['id'],
      code: json['code'],
      nomComplet: json['nom_complet'],
    );
  }

}


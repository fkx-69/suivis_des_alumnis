class StatDomaineModel {
  final String domaine;
  final int count;

  StatDomaineModel({required this.domaine, required this.count});

  factory StatDomaineModel.fromJson(Map<String, dynamic> json) {
    return StatDomaineModel(
      domaine: json['domaine'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

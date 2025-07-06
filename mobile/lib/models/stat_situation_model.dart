class StatSituationModel {
  final String situation;
  final int count;

  StatSituationModel({required this.situation, required this.count});

  factory StatSituationModel.fromJson(Map<String, dynamic> json) {
    return StatSituationModel(
      situation: json['situation'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

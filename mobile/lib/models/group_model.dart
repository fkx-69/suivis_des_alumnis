// lib/models/group_model.dart

class GroupModel {
  final int id;
  final String nomGroupe;
  final String description;
  final String? createur; // optionnel, selon ce que renvoie votre API

  GroupModel({
    required this.id,
    required this.nomGroupe,
    required this.description,
    this.createur,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
    id: json['id'] as int,
    nomGroupe: json['nom_groupe'] as String,
    description: json['description'] as String,
    createur: json['createur'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'nom_groupe': nomGroupe,
    'description': description,
    if (createur != null) 'createur': createur,
  };
}
// lib/models/group_member_model.dart

class GroupMemberModel {
  final int id;
  final String username;
  final String? nom;
  final String? prenom;
  final String? role;

  GroupMemberModel({
    required this.id,
    required this.username,
    this.nom,
    this.prenom,
    this.role,
  });

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) => GroupMemberModel(
    id: json['id'] as int,
    username: json['username'] as String,
    nom: json['nom'] as String?,
    prenom: json['prenom'] as String?,
    role: json['role'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    if (nom != null) 'nom': nom,
    if (prenom != null) 'prenom': prenom,
    if (role != null) 'role': role,
  };
}
// lib/models/group_message_model.dart

class GroupMessageModel {
  final int id;
  final int groupeId;
  final String message;
  final String auteurUsername;
  final DateTime dateEnvoi;

  GroupMessageModel({
    required this.id,
    required this.groupeId,
    required this.message,
    required this.auteurUsername,
    required this.dateEnvoi,
  });

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) =>
      GroupMessageModel(
        id: json['id'] as int,
        groupeId: json['groupe'] as int,
        message: json['message'] as String,
        auteurUsername: json['auteur_username'] as String,
        dateEnvoi: DateTime.parse(json['date_envoi'] as String),
      );

  Map<String, dynamic> toJson() => {
    'groupe': groupeId,
    'message': message,
  };
}

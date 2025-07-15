/// Représente un groupe de discussion
// lib/models/group_model.dart
class GroupModel {
  final int id;
  final String nomGroupe;
  final String description;
  final String createur;
  final bool isMember;
  final DateTime dateCreation;
  final String role;
  final String? photoProfil; // ⚠️ nullable (optionnelle)

  GroupModel({
    required this.id,
    required this.nomGroupe,
    required this.description,
    required this.createur,
    required this.isMember,
    required this.dateCreation,
    required this.role,
    this.photoProfil, // optionnelle
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    String _toStr(dynamic v) => v == null ? '' : v.toString();

    // parse est_membre en bool
    final rawMember = json['est_membre'];
    bool memberFlag;
    if (rawMember is bool) {
      memberFlag = rawMember;
    } else if (rawMember is String) {
      memberFlag = rawMember.toLowerCase() == 'true';
    } else if (rawMember is num) {
      memberFlag = rawMember == 1;
    } else {
      memberFlag = false;
    }

    // parse date
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(_toStr(json['date_creation']));
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return GroupModel(
      id: json['id'] as int,
      nomGroupe: _toStr(json['nom_groupe']),
      description: _toStr(json['description']),
      createur: _toStr(json['createur']),
      isMember: memberFlag,
      dateCreation: parsedDate,
      role: _toStr(json['role']),
      photoProfil: json['photo_profil'] as String?, // nullable
    );
  }
}


/// Représente un membre d’un groupe
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

  factory GroupMemberModel.fromJson(Map<String, dynamic> json) {
    final userMap = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : json;

    return GroupMemberModel(
      id: userMap['id'] as int,
      username: userMap['username'] as String,
      nom: userMap['nom'] as String?,
      prenom: userMap['prenom'] as String?,
      role: userMap['role'] as String?,
    );
  }

}
  /// Représente un message envoyé dans un groupe
// lib/models/group_model.dart

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

  factory GroupMessageModel.fromJson(Map<String, dynamic> json) {
    // debug print pour voir exactement le JSON
    // print('🔍 GroupMessage JSON: $json');

    String username;

    // 1) si l’API fournit un champ plat
    if (json['auteur_username'] is String) {
      username = json['auteur_username'] as String;
    }
    // 2) si 'auteur' est déjà une String
    else if (json['auteur'] is String) {
      username = json['auteur'] as String;
    }
    // 3) si 'auteur' est un objet contenant un champ 'username'
    else if (json['auteur'] is Map<String, dynamic> &&
        json['auteur']['username'] is String) {
      username = json['auteur']['username'] as String;
    }
    // 4) sinon on tombe sur un fallback
    else {
      username = 'Inconnu';
    }

    return GroupMessageModel(
      id: json['id'] as int,
      groupeId: json['groupe'] as int,
      message: json['contenu'] as String,
      auteurUsername: username,
      dateEnvoi: DateTime.parse(json['date_envoi'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'groupe': groupeId,
    'contenu': message,
  };
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "https://ton_domaine.com"; // <-- Remplace par ton vrai domaine

  // Connexion
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/api/login/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "success": true,
        "access": data["access"],
        "refresh": data["refresh"],
      };
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body),
      };
    }
  }

  // Inscription Étudiant
  static Future<Map<String, dynamic>> registerEtudiant({
    required String email,
    required String username,
    required String nom,
    required String prenom,
    required String password,
    required String filiere,
    required String niveauEtude,
    required int anneeEntree,
  }) async {
    final url = Uri.parse('$baseUrl/api/register/etudiant/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "user": {
          "email": email,
          "username": username,
          "nom": nom,
          "prenom": prenom,
          "password": password,
        },
        "filiere": filiere,
        "niveau_etude": niveauEtude,
        "annee_entree": anneeEntree,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {
        "success": true,
      };
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body),
      };
    }
  }

  // Inscription Alumni
  static Future<Map<String, dynamic>> registerAlumni({
    required String email,
    required String username,
    required String nom,
    required String prenom,
    required String password,
    required String dateFinCycle,
    required String secteurActivite,
    required String situationPro,
    required String posteActuel,
    required String nomEntreprise,
  }) async {
    final url = Uri.parse('$baseUrl/api/register/alumni/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "user": {
          "email": email,
          "username": username,
          "nom": nom,
          "prenom": prenom,
          "password": password,
        },
        "date_fin_cycle": dateFinCycle,
        "secteur_activite": secteurActivite,
        "situation_pro": situationPro,
        "poste_actuel": posteActuel,
        "nom_entreprise": nomEntreprise,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return {
        "success": true,
      };
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body),
      };
    }
  }

  // Obtenir les infos de l'utilisateur connecté
  static Future<Map<String, dynamic>> getUserInfo(String accessToken) async {
    final url = Uri.parse('$baseUrl/api/accounts/me/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        "success": true,
        "user": data,
      };
    } else {
      return {
        "success": false,
        "message": jsonDecode(response.body),
      };
    }
  }
}

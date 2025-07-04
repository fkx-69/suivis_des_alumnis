import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memoire/models/user_model.dart';
import 'package:memoire/models/publication_model.dart';
import 'package:memoire/models/event_model.dart';
import 'package:memoire/constants/api_constants.dart';
import 'package:memoire/models/comment_model.dart';

class HomeService {
  final client = http.Client();

  // 🔑 Récupérer le token d'accès
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access'); // clé à adapter selon ton projet
  }

  // 🔍 Suggestions de profils (auth requis)
  Future<List<UserModel>> fetchSuggestions() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await client.get(Uri.parse(ApiConstants.suggestions), headers: headers);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des suggestions');
    }
  }

  // 🔎 Recherche d'utilisateurs (publique)
  Future<List<UserModel>> searchUsers(String query) async {
    final url = Uri.parse('${ApiConstants.search}?q=$query');
    final response = await client.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors de la recherche');
    }
  }

  // 📰 Dernières publications (auth requis)
  Future<List<PublicationModel>> fetchPublications() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await client.get(Uri.parse(ApiConstants.feed), headers: headers);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => PublicationModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des publications');
    }
  }

  // 📅 Évènements à venir (auth requis ou pas selon ton backend)
  Future<List<EventModel>> fetchEvents() async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await client.get(Uri.parse(ApiConstants.events), headers: headers);
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => EventModel.fromJson(e)).toList();
    } else {
      throw Exception('Erreur lors du chargement des événements');
    }
  }
  Future<CommentModel> commenterPublication(int publicationId, String contenu) async {
    final token = await _getToken();
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = Uri.parse(ApiConstants.commenterPublication);
    final body = jsonEncode({
      'publication': publicationId,
      'contenu': contenu,
    });

    final response = await client.post(url, headers: headers, body: body);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return CommentModel.fromJson(data);
    } else {
      throw Exception('Erreur lors du commentaire');
    }
  }

}

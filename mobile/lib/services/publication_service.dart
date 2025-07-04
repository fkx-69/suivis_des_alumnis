import 'dart:io';
import 'package:dio/dio.dart';
import 'dio_client.dart';
import '../constants/api_constants.dart';
import '../models/publication_model.dart';
import '../models/comment_model.dart';

class PublicationService {
  final Dio _dio = DioClient.dio;

  /// Récupère le fil d’actualité complet
  Future<List<PublicationModel>> fetchFeed() async {
    final resp = await _dio.get(ApiConstants.publicationsFeed);
    return (resp.data as List)
        .map((j) => PublicationModel.fromJson(j))
        .toList();
  }

  /// Crée une nouvelle publication avec texte, photo ou vidéo
  Future<PublicationModel> createPublication({
    String? texte,
    File? photo,
    File? video,
  }) async {
    final form = FormData();
    if (texte != null && texte.isNotEmpty) {
      form.fields.add(MapEntry('texte', texte));
    }
    if (photo != null) {
      form.files.add(MapEntry(
          'photo',
          await MultipartFile.fromFile(photo.path,
              filename: photo.path.split('/').last)));
    }
    if (video != null) {
      form.files.add(MapEntry(
          'video',
          await MultipartFile.fromFile(video.path,
              filename: video.path.split('/').last)));
    }
    final resp = await _dio.post(ApiConstants.publicationsCreate,
        data: form);
    return PublicationModel.fromJson(resp.data);
  }

  /// Commente une publication

  Future<CommentModel> commentPublication(int pubId, String contenu) async {
    final resp = await _dio.post(ApiConstants.publicationsComment,
        data: {'publication': pubId, 'contenu': contenu});
    return CommentModel.fromJson(resp.data);
  }

  /// Supprime une publication

  Future<void> deletePublication(int pubId) async {
    final url = ApiConstants.publicationsDelete.replaceFirst('{id}', '$pubId');
    try {
      await _dio.delete(url);
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Erreur suppression publication';
      throw Exception(msg);
    }
  }
  Future<void> deleteComment(int commentId) async {
    final url = ApiConstants.publicationsDeleteComment(commentId);
    try {
      await _dio.delete(url);
    } on DioException catch (e) {
      final msg = e.response?.data['detail'] ?? 'Erreur suppression commentaire';
      throw Exception(msg);
    }
  }

}

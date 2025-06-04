import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memoire/services/publication_service.dart';

class PublicationForm extends StatefulWidget {
  final VoidCallback onPublished;
  const PublicationForm({super.key, required this.onPublished});

  @override
  State<PublicationForm> createState() => _PublicationFormState();
}

class _PublicationFormState extends State<PublicationForm> {
  final _service = PublicationService();
  final _texteController = TextEditingController();
  File? _photo, _video;
  bool _isLoading = false;

  Future<void> _pickPhoto() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _photo = File(file.path));
  }

  Future<void> _pickVideo() async {
    final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (file != null) setState(() => _video = File(file.path));
  }

  Future<void> _submit() async {
    if (_texteController.text.isEmpty && _photo == null && _video == null) {
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _service.createPublication(
        texte: _texteController.text.trim().isEmpty
            ? null
            : _texteController.text.trim(),
        photo: _photo,
        video: _video,
      );
      _texteController.clear();
      setState(() {
        _photo = null;
        _video = null;
      });
      widget.onPublished();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _texteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _texteController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: "Quoi de neuf ?",
                border: InputBorder.none,
              ),
            ),
            if (_photo != null) Image.file(_photo!),
            if (_video != null)
              Text("Vidéo sélectionnée : ${_video!.path.split('/').last}"),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: _pickPhoto,
                ),
                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: _pickVideo,
                ),
                const Spacer(),
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                    onPressed: _submit, child: const Text('Publier')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

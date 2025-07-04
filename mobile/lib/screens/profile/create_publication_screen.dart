import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/publication_service.dart';

class CreatePublicationScreen extends StatefulWidget {
  const CreatePublicationScreen({super.key});

  @override
  State<CreatePublicationScreen> createState() => _CreatePublicationScreenState();
}

class _CreatePublicationScreenState extends State<CreatePublicationScreen> {
  final PublicationService _publicationService = PublicationService();
  final TextEditingController _textController = TextEditingController();
  File? _mediaFile;
  final ImagePicker _picker = ImagePicker();
  bool _isPublishing = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _mediaFile = File(pickedFile.path));
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final pickedFile = await _picker.pickVideo(source: source);
    if (pickedFile != null) {
      setState(() => _mediaFile = File(pickedFile.path));
    }
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choisir une photo'),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.videocam),
            title: const Text('Choisir une vidéo'),
            onTap: () {
              Navigator.pop(context);
              _pickVideo(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  bool _isVideo(File file) {
    final path = file.path.toLowerCase();
    return path.endsWith('.mp4') || path.endsWith('.mov') || path.endsWith('.avi');
  }

  Future<void> _publish() async {
    if (_textController.text.isEmpty && _mediaFile == null) {
      Fluttertoast.showToast(msg: 'Veuillez ajouter du contenu');
      return;
    }

    setState(() => _isPublishing = true);

    try {
      await _publicationService.createPublication(
        texte: _textController.text,
        photo: _mediaFile != null && !_isVideo(_mediaFile!) ? _mediaFile : null,
        video: _mediaFile != null && _isVideo(_mediaFile!) ? _mediaFile : null,
      );
      Fluttertoast.showToast(msg: 'Publication envoyée avec succès');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Nouvelle publication', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(
            onPressed: _isPublishing ? null : _publish,
            child: Text(
              'Publier',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: _isPublishing ? Colors.grey : Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // En-tête utilisateur fictif
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: AssetImage('assets/images/default_avatar.png'),
                    ),
                    const SizedBox(width: 12),
                    Text('Moi', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 20),

                // Zone de texte avec style carte
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _textController,
                      maxLines: 6,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Exprimez ce que vous ressentez…',
                      ),
                      style: GoogleFonts.poppins(fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Media preview
                if (_mediaFile != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            image: !_isVideo(_mediaFile!)
                                ? DecorationImage(image: FileImage(_mediaFile!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _isVideo(_mediaFile!)
                              ? const Center(child: Icon(Icons.videocam, size: 64, color: Colors.grey))
                              : null,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => setState(() => _mediaFile = null),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                // Bouton ajouter média
                ElevatedButton.icon(
                  onPressed: _showMediaPicker,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Ajouter une image ou une vidéo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    side: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
          if (_isPublishing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

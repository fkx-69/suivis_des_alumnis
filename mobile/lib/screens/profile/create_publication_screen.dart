import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/publication_service.dart';

class CreatePublicationScreen extends StatefulWidget {
  const CreatePublicationScreen({super.key});

  @override
  State<CreatePublicationScreen> createState() => _CreatePublicationScreenState();
}

class _CreatePublicationScreenState extends State<CreatePublicationScreen> with TickerProviderStateMixin {
  final PublicationService _publicationService = PublicationService();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();
  File? _mediaFile;
  final ImagePicker _picker = ImagePicker();
  bool _isPublishing = false;
  bool _showCaptionField = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _showCaptionField = true;
      });
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    final pickedFile = await _picker.pickVideo(source: source);
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _showCaptionField = true;
      });
    }
  }

  void _showMediaPicker() {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Ajouter un média',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: colorScheme.secondary,
                  size: 24,
                ),
              ),
              title: Text(
                'Choisir une photo',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Sélectionner depuis la galerie',
                style: textTheme.bodySmall?.copyWith(
                  color: AppTheme.subTextColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.videocam,
                  color: colorScheme.secondary,
                  size: 24,
                ),
              ),
              title: Text(
                'Choisir une vidéo',
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Sélectionner depuis la galerie',
                style: textTheme.bodySmall?.copyWith(
                  color: AppTheme.subTextColor,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickVideo(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
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
      // Combiner le texte principal avec la légende si elle existe
      String finalText = _textController.text;
      if (_captionController.text.isNotEmpty) {
        finalText = finalText.isEmpty 
            ? _captionController.text 
            : '${_textController.text}\n\n${_captionController.text}';
      }

      await _publicationService.createPublication(
        texte: finalText,
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Nouvelle publication',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: ElevatedButton(
              onPressed: _isPublishing ? null : _publish,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.secondary,
                foregroundColor: Colors.black,
                elevation: 0,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: _isPublishing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      'Publier',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
            ),
          ),
        ],
        surfaceTintColor: Colors.transparent,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête utilisateur avec design amélioré
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppTheme.surfaceColor,
                            child: Icon(
                              Icons.person,
                              color: AppTheme.primaryColor,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Moi',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              Text(
                                'Partagez votre expérience',
                                style: textTheme.bodySmall?.copyWith(
                                  color: AppTheme.subTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Zone de texte avec design amélioré
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _textController,
                        maxLines: 6,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Partagez vos expériences, découvertes ou réflexions…',
                          hintStyle: textTheme.bodyMedium?.copyWith(
                            color: AppTheme.subTextColor.withOpacity(0.7),
                          ),
                        ),
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bouton ajouter média avec design amélioré
                  if (_mediaFile == null)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _showMediaPicker,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.add_photo_alternate,
                                    color: colorScheme.secondary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Ajouter un média',
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      Text(
                                        'Photo ou vidéo',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: AppTheme.subTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppTheme.subTextColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Media preview avec design amélioré
                  if (_mediaFile != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceColor,
                                    image: !_isVideo(_mediaFile!)
                                        ? DecorationImage(
                                            image: FileImage(_mediaFile!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: _isVideo(_mediaFile!)
                                      ? Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.play_circle_outline,
                                                size: 48,
                                                color: AppTheme.subTextColor.withOpacity(0.5),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Vidéo sélectionnée',
                                                style: textTheme.bodyMedium?.copyWith(
                                                  color: AppTheme.subTextColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    onPressed: () => setState(() {
                                      _mediaFile = null;
                                      _showCaptionField = false;
                                      _captionController.clear();
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Champ de légende
                          if (_showCaptionField)
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: TextField(
                                controller: _captionController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Ajouter une légende...',
                                  hintStyle: textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.subTextColor.withOpacity(0.7),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppTheme.borderColor),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: AppTheme.borderColor),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: colorScheme.secondary),
                                  ),
                                  contentPadding: const EdgeInsets.all(12),
                                ),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

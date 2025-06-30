// En-tête du fichier
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:memoire/models/publication_model.dart';
import 'package:memoire/services/publication_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PublicationService _pubSvc = PublicationService();
  List<PublicationModel> _feed = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() => _isLoading = true);
    try {
      _feed = await _pubSvc.fetchFeed();
    } catch (e) {
      // tu peux ajouter un SnackBar ou un log ici
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadFeed,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // … ton header et search bar …
                _buildFeedSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeedSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fil d’actualité',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_feed.isEmpty)
            Text('Aucune publication pour le moment',
                style: GoogleFonts.poppins(color: Colors.grey))
          else
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _feed.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) {
                final p = _feed[i];
                final time = DateFormat('dd/MM – HH:mm').format(p.datePublication);

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête auteur + date
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey.shade300,
                              // tu peux remplacer par NetworkImage si tu ajoutes photo_profil
                              // backgroundImage: NetworkImage(p.auteurPhotoUrl!),
                            ),
                            const SizedBox(width: 8),
                            Text(p.auteurUsername,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text(time,
                                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Texte
                        if (p.texte != null && p.texte!.isNotEmpty)
                          Text(p.texte!, style: GoogleFonts.poppins()),

                        // Photo
                        if (p.photo != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                p.photo!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            ),
                          ),

                        // Vidéo (simple placeholder)
                        if (p.video != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(child: Icon(Icons.play_circle_outline, size: 64)),
                            ),
                          ),

                        const SizedBox(height: 12),

                        // Pied de carte : commentaires
                        Row(
                          children: [
                            const Icon(Icons.comment_outlined, size: 20, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('${p.commentaires.length}',
                                style: GoogleFonts.poppins(color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

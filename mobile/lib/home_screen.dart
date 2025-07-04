import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:memoire/models/user_model.dart';
import 'package:memoire/models/publication_model.dart';
import 'package:memoire/models/event_model.dart';
import 'package:memoire/screens/profile/public_profile_screen.dart';
import 'package:memoire/services/home_service.dart';
import 'package:memoire/screens/event/event_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = HomeService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<UserModel> _suggestions = [];
  List<PublicationModel> _publications = [];
  List<EventModel> _events = [];

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      final suggestions = await _homeService.fetchSuggestions();
      final publications = await _homeService.fetchPublications();
      final events = await _homeService.fetchEvents();
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
        _publications = publications;
        _events = events;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) {
      _loadContent();
      return;
    }
    try {
      final results = await _homeService.searchUsers(query);
      setState(() {
        _suggestions = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de recherche : $e')),
      );
    }
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: _search,
      decoration: InputDecoration(
        hintText: 'Rechercher un utilisateur...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple.shade400, width: 2),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPublicationCard(PublicationModel post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Auteur + date
            Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person)),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@${post.auteurUsername}',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text(
                      DateFormat.yMMMd('fr_FR').add_Hm().format(post.datePublication),
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 📸 Photo ou 🎥 Vidéo
            if (post.photo != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(post.photo!, fit: BoxFit.cover),
              )
            else if (post.video != null)
              Container(
                height: 200,
                color: Colors.black12,
                child: const Center(child: Icon(Icons.videocam, size: 60)),
              ),

            const SizedBox(height: 12),

            // 📝 Texte de la publication
            if (post.texte != null && post.texte!.isNotEmpty)
              Text(post.texte!,
                  style: GoogleFonts.poppins(fontSize: 15)),

            const SizedBox(height: 12),

            // 💬 Commentaires (max 2)
            if (post.commentaires.isNotEmpty) ...[
              const Divider(),
              ...post.commentaires.take(2).map((comment) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.comment, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('@${comment.auteurUsername}',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(comment.contenu,
                              style: GoogleFonts.poppins(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              if (post.nombresCommentaires != null &&
                  post.commentaires.length > 2)
                TextButton(
                  onPressed: () {
                    // Naviguer vers PublicationDetailScreen si nécessaire
                  },
                  child: const Text("Voir tous les commentaires"),
                )
            ],

            // ➕ Ajouter un commentaire
            const Divider(),
            Row(
              children: [
                const Icon(Icons.edit, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Ajouter un commentaire...',
                      hintStyle: GoogleFonts.poppins(fontSize: 13),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (text) async {
                      if (text.trim().isEmpty) return;
                      try {
                        await _homeService.commenterPublication(post.id, text);
                        await _loadContent(); // recharger
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: $e')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.school, color: Colors.blue),
        title: Text('AlumniFy',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.blue)),
        centerTitle: false,
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.account_balance, color: Colors.white),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadContent,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),

            _buildSectionTitle('Suggestions de profils'),
            _suggestions.isEmpty
                ? const Text('Aucune suggestion disponible.')
                : SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final user = _suggestions[index];
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: user.photoProfil != null
                              ? NetworkImage(user.photoProfil!)
                              : null,
                          child: user.photoProfil == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(height: 8),
                        Text(user.prenom,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis),
                        Text(user.nom,
                            style: GoogleFonts.poppins(fontSize: 12),
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PublicProfileScreen(username: user.username),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize:
                            const Size.fromHeight(32),
                          ),
                          child: const Text('Voir profil',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Dernières publications'),
            _publications.isEmpty
                ? const Text('Aucune publication disponible.')
                : Column(
              children:
              _publications.map(_buildPublicationCard).toList(),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Évènements à venir'),
            Builder(
              builder: (context) {
                final upcomingValidated = _events.where((e) =>
                e.valide && e.dateFin.isAfter(DateTime.now())
                ).toList();

                if (upcomingValidated.isEmpty) {
                  return const Text('Aucun évènement prévu.');
                }

                return Column(
                  children: upcomingValidated.map((e) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(e.titre),
                        subtitle: Text(
                          '${DateFormat('dd MMM yyyy').format(e.dateDebut)} - ${DateFormat('dd MMM yyyy').format(e.dateFin)}',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EventDetailScreen(event: e),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}

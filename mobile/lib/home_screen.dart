import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:memoire/models/user_model.dart';
import 'package:memoire/models/publication_model.dart';
import 'package:memoire/models/event_model.dart';
import 'package:memoire/screens/event/event_detail_screen.dart';
import 'package:memoire/services/home_service.dart';
import 'package:memoire/services/event_provider.dart';
import 'package:memoire/widgets/publication_card.dart';
import 'package:memoire/widgets/home/section_title.dart';
import 'package:memoire/widgets/home/search_bar.dart';
import 'package:memoire/widgets/home/user_suggestion_section.dart';
import 'package:memoire/widgets/event/event_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final HomeService _homeService = HomeService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<UserModel> _suggestions = [];
  List<PublicationModel> _publications = [];
  List<EventModel> _events = [];

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _loadContent();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    setState(() => _isLoading = true);
    try {
      final suggestions = await _homeService.fetchSuggestions();
      final publications = await _homeService.fetchPublications();
      
      // Charger les événements via le Provider
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<EventProvider>().loadAllEvents();
      });
      
      if (!mounted) return;
      setState(() {
        _suggestions = suggestions;
        _publications = publications;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.errorColor,
            content: Text('Erreur de chargement : $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _fadeController.forward();
      }
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
        SnackBar(
          backgroundColor: AppTheme.errorColor,
          content: Text('Erreur de recherche : $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final colorScheme = theme.colorScheme;
    final isSmallScreen = size.width < 400;
    final horizontalPadding = size.width * 0.05 > 24 ? 24.0 : size.width * 0.05;
    final verticalPadding = size.height * 0.02 > 20 ? 20.0 : size.height * 0.02;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              backgroundColor: AppTheme.backgroundColor,
              elevation: 0,
              floating: true,
              pinned: true,
              expandedHeight: isSmallScreen ? 90 : 120,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.secondary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: Row(
                        children: [
                          // Titre
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'AlumniFy',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                                Text(
                                  'Réseau des ITMIENS',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Logo
                          Container(
                            width: isSmallScreen ? 32 : 40,
                            height: isSmallScreen ? 32 : 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                'assets/images/logo.jpeg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Contenu principal
            SliverToBoxAdapter(
              child: _isLoading
                  ? SizedBox(
                height: size.height * 0.4,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.secondary),
                  ),
                ),
              )
                  : Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SearchBarWidget(
                      controller: _searchController,
                      onChanged: _search,
                    ),
                    SizedBox(height: size.height * 0.025),

                    const SectionTitle(title: 'Suggestions de profils'),
                    Row(
                      children: [
                        Expanded(
                          child: _suggestions.isEmpty
                              ? const Center(child: Text("Aucune suggestion disponible."))
                              : UserSuggestionSection(users: _suggestions),
                        ),
                        IconButton(
                          onPressed: () {
                            print("🔄 Test: Rechargement des suggestions...");
                            _loadContent();
                          },
                          icon: const Icon(Icons.refresh),
                          tooltip: "Recharger",
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.03),

                    const SectionTitle(title: 'Dernières publications'),
                    if (_publications.isEmpty)
                      const Center(child: Text("Aucune publication disponible."))
                    else
                      Column(
                        children: _publications
                            .map((pub) => Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.02),
                          child: PublicationCard(publication: pub),
                        ))
                            .toList(),
                      ),


                    SizedBox(height: size.height * 0.03),
                    const SectionTitle(title: 'Évènements à venir'),
                    const SizedBox(height: 12),

                    Consumer<EventProvider>(
                      builder: (context, eventProvider, child) {
                        final eventList = eventProvider.upcomingEvents;
                        final isLoading = eventProvider.isLoading;

                        if (isLoading) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 8.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (eventList.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.borderColor,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_outlined,
                                  size: 48,
                                  color: AppTheme.subTextColor.withOpacity(0.5),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Aucun événement à venir",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.subTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Soyez le premier à créer un événement !",
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppTheme.subTextColor.withOpacity(0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        return Column(
                          children: [
                            SizedBox(
                              height: 270,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                itemCount: eventList.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final event = eventList[index];
                                  return SizedBox(
                                    width: 280,
                                    child: EventCard(
                                      event: event,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EventDetailScreen(event: event),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                "${eventList.length} événement${eventList.length > 1 ? 's' : ''} trouvé${eventList.length > 1 ? 's' : ''}",
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.subTextColor.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

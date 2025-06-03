import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/event/event_list_view.dart';
import '../auth/home_screen.dart';
import '../profile/profile_screen.dart';
import 'event_detail_screen.dart';
import 'create_event_screen.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final _service = EventService();
  List<EventModel> _events = [];
  bool _loading = true;
  int _selectedIndex = 1; // 0=Home,1=Events,2=Messages,3=Profile

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    _events = await _service.fetchCalendar();
    setState(() => _loading = false);
  }

  void _onNavTap(int idx) {
    if (idx == _selectedIndex) return;
    switch (idx) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        break;
      case 1:
      // déjà sur Événements
        break;
      case 2:

        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Événements'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Créer',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
              );
              _loadEvents();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadEvents,
        child: EventListView(
          events: _events,
          onEventTap: (e) async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EventDetailScreen(event: e)),
            );
            _loadEvents();
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/event/event_list_view.dart';
import '../auth/home_screen.dart';
import '../profile/profile_screen.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';
import 'package:memoire/screens/group/group_list_screen.dart';

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
    final fetched = await _service.fetchCalendar();
    final now = DateTime.now();
    final upcoming = fetched.where((e) => e.dateDebut.isAfter(now)).toList();
    setState(() {
      _events = upcoming;
      _loading = false;
    });
  }

  void _onNavTap(int idx) {
    if (idx == _selectedIndex) return;
    switch (idx) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GroupListScreen()));
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('Événements', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF2196F3)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadEvents,
        color: const Color(0xFF4CAF50),
        child: EventListView(
          events: _events,
          onEventTap: (e) async {
            final modified = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (_) => EventDetailScreen(event: e)),
            );
            if (modified == true) await _loadEvents();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventScreen()),
          );
          if (created == true) await _loadEvents();
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

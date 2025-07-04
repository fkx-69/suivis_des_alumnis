import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import 'event_detail_screen.dart';
import '../../widgets/event/event_list_view.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  final _service = EventService();
  List<EventModel> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final fetched = await _service.fetchCalendar();
    final now = DateTime.now();
    final upcomingValidated = fetched
        .where((e) => e.dateDebut.isAfter(now) && e.valide)
        .toList();
    if (mounted) {
      setState(() {
        _events = upcomingValidated;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
      onRefresh: _loadEvents,
      child: EventListView(
        events: _events,
        onEventTap: (e) async {
          final modified = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => EventDetailScreen(event: e),
            ),
          );
          if (modified == true) await _loadEvents();
        },
      ),
    );
  }
}

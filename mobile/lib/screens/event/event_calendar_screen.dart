import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/app_bottom_nav_bar.dart';
import 'create_event_screen.dart';
import 'event_detail_screen.dart';

class EventCalendarScreen extends StatefulWidget {
  const EventCalendarScreen({super.key});
  @override
  State<EventCalendarScreen> createState() => _EventCalendarScreenState();
}

class _EventCalendarScreenState extends State<EventCalendarScreen> {
  final EventService _svc = EventService();
  Map<DateTime, List<EventModel>> _events = {};
  List<EventModel> _selectedEvents = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _loading = true;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    print('🔄 Chargement calendrier');
    setState(() => _loading = true);
    final list = await _svc.fetchCalendar();
    print('🔄 Événements totaux reçus : ${list.length}');
    final Map<DateTime, List<EventModel>> map = {};
    for (var e in list) {
      final day = DateTime(e.dateDebut.year, e.dateDebut.month, e.dateDebut.day);
      map.putIfAbsent(day, () => []).add(e);
    }
    setState(() {
      _events = map;
      _selectedDay = _focusedDay;
      _selectedEvents = _events[_selectedDay!] ?? [];
      _loading = false;
    });
  }

  List<EventModel> _getEventsForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _events[d] ?? [];
  }

  void _onNavTap(int idx) {
    if (idx == _selectedIndex) return;
    switch (idx) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/messages');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
    setState(() => _selectedIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Calendrier')),
      body: Column(
        children: [
          TableCalendar<EventModel>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
            eventLoader: _getEventsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              outsideDaysVisible: false,
            ),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
                _selectedEvents = _getEventsForDay(selected);
              });
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _selectedEvents.isEmpty
                ? const Center(child: Text("Aucun événement"))
                : ListView.builder(
              itemCount: _selectedEvents.length,
              itemBuilder: (_, i) {
                final ev = _selectedEvents[i];
                return ListTile(
                  title: Text(ev.titre),
                  subtitle:
                  Text("${ev.dateDebutAffiche} – ${ev.dateFinAffiche}"),
                  onTap: () async {
                    final modified = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(event: ev),
                      ),
                    );
                    print('✏️ EventDetailScreen returned: $modified');
                    if (modified == true) {
                      await _loadAll();
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => CreateEventScreen(initialDay: _selectedDay),
            ),
          );
          print('📝 CreateEventScreen returned: $created');
          if (created == true) {
            await _loadAll();
          }
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

import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import 'event_card.dart';

class EventListView extends StatelessWidget {
  final List<EventModel> events;
  final ValueChanged<EventModel> onEventTap;

  const EventListView({
    super.key,
    required this.events,
    required this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Center(
        child: Text('Aucun événement', style: TextStyle(fontSize: 16, color: Colors.grey)),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        itemCount: events.length,
        itemBuilder: (ctx, i) {
          final ev = events[i];
          return EventCard(event: ev, onTap: () => onEventTap(ev));
        },
      ),
    );
  }
}

// lib/screens/events/edit_event_screen.dart

import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import 'package:memoire/widgets/event/event_form.dart';

class EditEventScreen extends StatelessWidget {
  final EventModel event;
  const EditEventScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier l’événement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: EventForm(
          initial: event,
          onSubmit: (e) async {
            await EventService().updateEvent(e.id, e);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}

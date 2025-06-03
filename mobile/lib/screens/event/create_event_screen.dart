// lib/screens/events/create_event_screen.dart

import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import 'package:memoire/widgets/event/event_form.dart';

class CreateEventScreen extends StatelessWidget {
  final DateTime? initialDay;
  const CreateEventScreen({super.key, this.initialDay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un événement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: EventForm(
          initial: initialDay == null
              ? null
              : EventModel(
            id: 0,
            titre: '',
            description: '',
            dateDebut: initialDay!,
            dateFin:   initialDay!.add(const Duration(hours: 1)),
          ),
          onSubmit: (ev) async {
            final body = ev.toJson();
            print('→ Création événement payload : $body');
            try {
              await EventService().createEvent(ev);
              Navigator.pop(context);
            } catch (e) {
              print('Erreur création événement : $e');
              rethrow;
            }
          },

        ),
      ),
    );
  }
}

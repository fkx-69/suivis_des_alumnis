import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/event/event_form.dart';

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
            try {
              await EventService().updateEvent(e.id, e);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Événement mis à jour')),
              );
              Navigator.pop(context, true);
            } catch (e) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur mise à jour : $e')),
              );
            }
          },
        ),
      ),
    );
  }
}

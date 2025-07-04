import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../widgets/event/event_form.dart';

class CreateEventScreen extends StatelessWidget {
  final DateTime? initialDay;
  const CreateEventScreen({super.key, this.initialDay});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Header en gradient
      body: Stack(
        children: [
          Container(
            height: 200,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF00BCD4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar custom
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        'Créer un événement',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),

                // Formulaire
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      clipBehavior: Clip.hardEdge,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: EventForm(
                          initial: initialDay == null
                              ? null
                              : EventModel(
                            id: 0,
                            titre: '',
                            description: '',
                            dateDebut: initialDay!,
                            dateFin: initialDay!.add(const Duration(hours: 1)),
                          ),
                          onSubmit: (event, image) async {
                            try {
                              await EventService().createEvent(event, image: image);
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Événement créé avec succès !')),
                              );
                              Navigator.pop(context, true);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur lors de la création : $e')),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

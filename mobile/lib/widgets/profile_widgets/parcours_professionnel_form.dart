// lib/screens/profile/widgets/parcours_professionnel_form.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef ProfCreate = Future<void> Function(Map<String, dynamic> data);
typedef ProfUpdate = Future<void> Function(int id, Map<String, dynamic> data);
typedef ProfDelete = Future<void> Function(int id);

class ParcoursProfessionnelFormSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final ProfCreate onCreate;
  final ProfUpdate onUpdate;
  final ProfDelete onDelete;

  const ParcoursProfessionnelFormSection({
    super.key,
    required this.items,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
  });

  static const List<String> _contrats = [
    'CDI', 'CDD', 'Stage', 'Alternance', 'Freelance'
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Ajouter Parcours Pro'),
          onPressed: () => _showForm(context),
        ),
        const SizedBox(height: 16),
        for (var item in items)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(item['poste'] ?? '',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  '${item['entreprise']} • ${item['date_debut']} (${item['type_contrat']})',
                  style: GoogleFonts.poppins(fontSize: 13)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showForm(context, existing: item),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => onDelete(item['id']),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _showForm(BuildContext ctx, {Map<String, dynamic>? existing}) {
    final formKey = GlobalKey<FormState>();
    final posteCtrl = TextEditingController(text: existing?['poste']);
    final entCtrl = TextEditingController(text: existing?['entreprise']);
    final dateCtrl =
    TextEditingController(text: existing?['date_debut']);
    String contrat = existing?['type_contrat'] ?? _contrats.first;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      builder: (bottomSheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                controller: posteCtrl,
                decoration: const InputDecoration(labelText: 'Poste *'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: entCtrl,
                decoration: const InputDecoration(labelText: 'Entreprise *'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: dateCtrl,
                decoration:
                const InputDecoration(labelText: 'Date début *'),
                readOnly: true,
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: existing != null
                        ? DateTime.parse(existing['date_debut'])
                        : DateTime.now(),
                    firstDate: DateTime(1970),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) dateCtrl.text = d.toIso8601String().split('T').first;
                },
                validator: (v) =>
                v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: contrat,
                items: _contrats
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => contrat = v!,
                decoration: const InputDecoration(labelText: 'Type contrat'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final data = {
                    'poste': posteCtrl.text,
                    'entreprise': entCtrl.text,
                    'date_debut': dateCtrl.text,
                    'type_contrat': contrat,
                  };
                  if (existing != null) {
                    onUpdate(existing['id'], data);
                  } else {
                    onCreate(data);
                  }
                  Navigator.pop(ctx);
                },
                child:
                Text(existing != null ? 'Modifier' : 'Créer'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

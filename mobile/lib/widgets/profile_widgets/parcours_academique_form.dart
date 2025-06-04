// lib/screens/profile/widgets/parcours_academique_form.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef AcadCreate = Future<void> Function(Map<String, dynamic> data);
typedef AcadUpdate = Future<void> Function(int id, Map<String, dynamic> data);
typedef AcadDelete = Future<void> Function(int id);

class ParcoursAcademiqueFormSection extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final AcadCreate onCreate;
  final AcadUpdate onUpdate;
  final AcadDelete onDelete;

  const ParcoursAcademiqueFormSection({
    super.key,
    required this.items,
    required this.onCreate,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Ajouter Parcours Académique'),
          onPressed: () => _showForm(context),
        ),
        const SizedBox(height: 16),
        for (var item in items)
          Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              title: Text(item['diplome'] ?? '',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              subtitle: Text(
                  '${item['institution']}, ${item['annee_obtention']}\n${item['mention'] ?? ''}',
                  style: GoogleFonts.poppins(fontSize: 13)),
              isThreeLine: true,
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
    final dipCtrl = TextEditingController(text: existing?['diplome']);
    final instCtrl = TextEditingController(text: existing?['institution']);
    final anCtrl = TextEditingController(
        text: existing != null ? existing['annee_obtention'].toString() : '');
    final menCtrl = TextEditingController(text: existing?['mention']);

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
                controller: dipCtrl,
                decoration: const InputDecoration(labelText: 'Diplôme *'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: instCtrl,
                decoration: const InputDecoration(labelText: 'Institution *'),
                validator: (v) =>
                v == null || v.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: anCtrl,
                decoration:
                const InputDecoration(labelText: 'Année obtention *'),
                keyboardType: TextInputType.number,
                validator: (v) =>
                v == null || int.tryParse(v) == null ? 'Nombre requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: menCtrl,
                decoration: const InputDecoration(labelText: 'Mention'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final data = {
                    'diplome': dipCtrl.text,
                    'institution': instCtrl.text,
                    'annee_obtention': int.parse(anCtrl.text),
                    'mention': menCtrl.text.isEmpty ? null : menCtrl.text,
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

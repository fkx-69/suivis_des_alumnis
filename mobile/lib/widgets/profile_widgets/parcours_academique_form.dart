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

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            icon: const Icon(Icons.add),
            label: Text('Ajouter parcours académique', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
            onPressed: () => _showForm(context),
          ),
        ),
        const SizedBox(height: 16),
        for (var item in items)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: ListTile(
                title: Text(
                  item['diplome'] ?? '',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${item['institution']}, ${item['annee_obtention']}\n${item['mention'] ?? ''}',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
                      onPressed: () => _showForm(context, existing: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => onDelete(item['id']),
                    ),
                  ],
                ),
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
      text: existing != null ? existing['annee_obtention'].toString() : '',
    );
    final menCtrl = TextEditingController(text: existing?['mention']);

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 16,
            bottom: MediaQuery.of(bCtx).viewInsets.bottom + 16,
          ),
          child: ListView(
            controller: controller,
            shrinkWrap: true,
            children: [
              Text(
                existing != null ? 'Modifier parcours' : 'Nouveau parcours',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: dipCtrl,
                      decoration: _fieldDecoration('Diplôme *'),
                      validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: instCtrl,
                      decoration: _fieldDecoration('Institution *'),
                      validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: anCtrl,
                      decoration: _fieldDecoration('Année obtention *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || int.tryParse(v) == null ? 'Nombre requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: menCtrl,
                      decoration: _fieldDecoration('Mention'),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
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
                        child: Text(
                          existing != null ? 'Modifier' : 'Créer',
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

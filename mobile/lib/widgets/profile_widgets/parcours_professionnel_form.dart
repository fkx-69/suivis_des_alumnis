import 'package:flutter/material.dart';
import '../../../constants/app_theme.dart';

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

  static const List<Map<String, String>> _contrats = [
    {'value': 'CDI', 'label': 'CDI'},
    {'value': 'CDD', 'label': 'CDD'},
    {'value': 'stage', 'label': 'Stage'},
    {'value': 'freelance', 'label': 'Freelance'},
    {'value': 'autre', 'label': 'Autre'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_business),
            label: const Text('Ajouter parcours pro'),
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
              color: AppTheme.cardColor,
              child: ListTile(
                title: Text(
                  item['poste'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  '${item['entreprise']} • ${item['date_debut']} (${item['type_contrat']})',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppTheme.accentColor),
                      onPressed: () => _showForm(context, existing: item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: AppTheme.errorColor),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirmation'),
                            content: const Text('Voulez-vous vraiment supprimer ce parcours ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text(
                                  'Supprimer',
                                  style: TextStyle(color: AppTheme.errorColor),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          onDelete(item['id']);
                        }
                      },
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
    final posteCtrl = TextEditingController(text: existing?['poste']);
    final entCtrl = TextEditingController(text: existing?['entreprise']);
    final dateCtrl = TextEditingController(text: existing?['date_debut']);
    String selectedType = existing?['type_contrat'] ?? _contrats.first['value']!;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bCtx) => DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                existing != null ? 'Modifier parcours pro' : 'Nouveau parcours pro',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: posteCtrl,
                      decoration: const InputDecoration(labelText: 'Poste *'),
                      validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: entCtrl,
                      decoration: const InputDecoration(labelText: 'Entreprise *'),
                      validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: dateCtrl,
                      decoration: const InputDecoration(labelText: 'Date début *'),
                      readOnly: true,
                      onTap: () async {
                        final d = await showDatePicker(
                          context: bCtx,
                          initialDate: existing != null
                              ? DateTime.parse(existing['date_debut'])
                              : DateTime.now(),
                          firstDate: DateTime(1970),
                          lastDate: DateTime.now(),
                        );
                        if (d != null) {
                          dateCtrl.text = d.toIso8601String().split('T').first;
                        }
                      },
                      validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedType,
                      decoration: const InputDecoration(labelText: 'Type de contrat *'),
                      items: _contrats.map((c) {
                        return DropdownMenuItem(
                          value: c['value'],
                          child: Text(c['label']!),
                        );
                      }).toList(),
                      onChanged: (v) => selectedType = v!,
                      validator: (v) => v == null ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final data = {
                            'poste': posteCtrl.text,
                            'entreprise': entCtrl.text,
                            'date_debut': dateCtrl.text,
                            'type_contrat': selectedType,
                          };
                          if (existing != null) {
                            onUpdate(existing['id'], data);
                          } else {
                            onCreate(data);
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(existing != null ? 'Modifier' : 'Créer'),
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

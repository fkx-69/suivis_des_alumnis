import 'package:flutter/material.dart';
import '../../../constants/app_theme.dart';

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

  static const List<String> _mentionsDisponibles = [
    'mention_passable',
    'mention_assez_bien',
    'mention_bien',
    'mention_tres_bien',
    'mention_excellent',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Ajouter parcours académique'),
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
                  item['diplome'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(
                  '${item['institution']}, ${item['annee_obtention']}\n${item['mention'] ?? ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                isThreeLine: true,
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
    final dipCtrl = TextEditingController(text: existing?['diplome']);
    final instCtrl = TextEditingController(text: existing?['institution']);
    final anCtrl = TextEditingController(
      text: existing != null ? existing['annee_obtention'].toString() : '',
    );
    String? selectedMention = existing?['mention'];

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
                existing != null ? 'Modifier parcours' : 'Nouveau parcours',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: dipCtrl,
                      decoration: const InputDecoration(labelText: 'Diplôme *'),
                      validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: instCtrl,
                      decoration: const InputDecoration(labelText: 'Institution *'),
                      validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: anCtrl,
                      decoration: const InputDecoration(labelText: 'Année obtention *'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || int.tryParse(v) == null ? 'Nombre requis' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedMention != null && _mentionsDisponibles.contains(selectedMention)
                          ? selectedMention
                          : null,
                      decoration: const InputDecoration(labelText: 'Mention'),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Aucune'),
                        ),
                        ..._mentionsDisponibles.map((mention) => DropdownMenuItem<String>(
                          value: mention,
                          child: Text(mention),
                        )),
                      ],
                      onChanged: (val) {
                        selectedMention = val;
                      },
                      isExpanded: true,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (!formKey.currentState!.validate()) return;
                          final data = {
                            'diplome': dipCtrl.text,
                            'institution': instCtrl.text,
                            'annee_obtention': int.parse(anCtrl.text),
                            'mention': selectedMention,
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

import 'package:flutter/material.dart';
import 'package:memoire/models/reponse_enquete_model.dart';
import 'package:memoire/services/enquete_service.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:intl/intl.dart';

class EnqueteFormScreen extends StatefulWidget {
  const EnqueteFormScreen({super.key});

  @override
  State<EnqueteFormScreen> createState() => _EnqueteFormScreenState();
}

class _EnqueteFormScreenState extends State<EnqueteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  bool _aTrouveEmploi = false;
  DateTime? _dateDebutEmploi;
  String _domaine = 'informatique';
  String? _autreDomaine;
  double _noteInsertion = 3;
  String? _suggestions;

  final List<String> _domaines = [
    'informatique',
    'reseaux',
    'telecoms',
    'gestion',
    'droit',
    'autre',
  ];

  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final reponse = ReponseEnqueteModel(
      aTrouveEmploi: _aTrouveEmploi,
      dateDebutEmploi: _aTrouveEmploi ? _dateDebutEmploi : null,
      domaine: _domaine,
      autreDomaine: _domaine == 'autre' ? _autreDomaine : null,
      noteInsertion: _noteInsertion.round(),
      suggestions: _suggestions,
    );

    setState(() => _isLoading = true);

    try {
      await EnqueteService().submitReponseEnquete(reponse);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Réponse enregistrée avec succès.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
    );

    if (date != null) {
      setState(() => _dateDebutEmploi = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Enquête d\'insertion'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Avez-vous trouvé un emploi ?'),
                value: _aTrouveEmploi,
                onChanged: (val) => setState(() => _aTrouveEmploi = val),
                activeColor: AppTheme.accentColor,
              ),
              if (_aTrouveEmploi) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date de début d\'emploi',
                    ),
                    child: Text(
                      _dateDebutEmploi != null
                          ? DateFormat.yMMMMd('fr_FR').format(_dateDebutEmploi!)
                          : 'Choisir une date',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Domaine'),
                value: _domaine,
                items: _domaines
                    .map((d) => DropdownMenuItem(
                  value: d,
                  child: Text(d[0].toUpperCase() + d.substring(1)),
                ))
                    .toList(),
                onChanged: (val) => setState(() => _domaine = val!),
              ),
              if (_domaine == 'autre') ...[
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Autre domaine'),
                  onSaved: (val) => _autreDomaine = val,
                ),
              ],
              const SizedBox(height: 24),
              Text('Note d\'insertion (${_noteInsertion.round()}/5)'),
              Slider(
                value: _noteInsertion,
                min: 1,
                max: 5,
                divisions: 4,
                label: _noteInsertion.round().toString(),
                activeColor: AppTheme.accentColor,
                onChanged: (val) => setState(() => _noteInsertion = val),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Suggestions (optionnel)'),
                maxLines: 4,
                onSaved: (val) => _suggestions = val,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Envoyer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// lib/widgets/event/event_form.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';

typedef EventFormSubmit = Future<void> Function(EventModel event);

class EventForm extends StatefulWidget {
  final EventModel? initial;
  final EventFormSubmit onSubmit;

  const EventForm({
    super.key,
    this.initial,
    required this.onSubmit,
  });

  @override
  State<EventForm> createState() => _EventFormState();
}

class _EventFormState extends State<EventForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titreCtl;
  late TextEditingController _descCtl;
  late DateTime _date;
  late TimeOfDay _timeStart;
  late TimeOfDay _timeEnd;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    _titreCtl = TextEditingController(text: init?.titre ?? '');
    _descCtl  = TextEditingController(text: init?.description ?? '');
    if (init != null) {
      _date = DateTime(init.dateDebut.year, init.dateDebut.month, init.dateDebut.day);
      _timeStart = TimeOfDay.fromDateTime(init.dateDebut);
      _timeEnd   = TimeOfDay.fromDateTime(init.dateFin);
    } else {
      final now = DateTime.now();
      _date = now;
      _timeStart = TimeOfDay.fromDateTime(now);
      _timeEnd   = TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)));
    }
  }

  @override
  void dispose() {
    _titreCtl.dispose();
    _descCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _pickTimeStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeStart,
    );
    if (picked != null) {
      setState(() => _timeStart = picked);
    }
  }

  Future<void> _pickTimeEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeEnd,
    );
    if (picked != null) {
      setState(() => _timeEnd = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final dtDebut = DateTime(
      _date.year, _date.month, _date.day,
      _timeStart.hour, _timeStart.minute,
    );
    final dtFin = DateTime(
      _date.year, _date.month, _date.day,
      _timeEnd.hour, _timeEnd.minute,
    );

    final ev = EventModel(
      id: widget.initial?.id ?? 0,
      titre: _titreCtl.text.trim(),
      description: _descCtl.text.trim(),
      dateDebut: dtDebut,
      dateFin: dtFin,
      dateDebutAffiche: DateFormat.yMMMd().add_Hm().format(dtDebut),
      dateFinAffiche: DateFormat.yMMMd().add_Hm().format(dtFin),
      createur: widget.initial?.createur,
    );

    await widget.onSubmit(ev);
  }

  @override
  Widget build(BuildContext context) {
    final fmtDate   = DateFormat.yMMMMd().format(_date);
    final fmtStart  = _timeStart.format(context);
    final fmtEnd    = _timeEnd.format(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _titreCtl,
            decoration: const InputDecoration(labelText: 'Titre'),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descCtl,
            decoration: const InputDecoration(labelText: 'Description'),
            minLines: 2,
            maxLines: 4,
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickDate,
                  child: Text('Date : $fmtDate', style: GoogleFonts.poppins()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickTimeStart,
                  child: Text('Début : $fmtStart', style: GoogleFonts.poppins()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickTimeEnd,
                  child: Text('Fin   : $fmtEnd', style: GoogleFonts.poppins()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              child: Text(
                widget.initial == null ? 'Créer' : 'Enregistrer',
                style: GoogleFonts.poppins(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    _descCtl = TextEditingController(text: init?.description ?? '');
    final now = DateTime.now();
    if (init != null) {
      _date = DateTime(init.dateDebut.year, init.dateDebut.month, init.dateDebut.day);
      _timeStart = TimeOfDay.fromDateTime(init.dateDebut);
      _timeEnd = TimeOfDay.fromDateTime(init.dateFin);
    } else {
      _date = now;
      _timeStart = TimeOfDay.fromDateTime(now);
      _timeEnd = TimeOfDay.fromDateTime(now.add(const Duration(hours: 1)));
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
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2196F3), // header
            onPrimary: Colors.white,     // header text
            onSurface: Colors.black,     // body text
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTimeStart() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeStart,
    );
    if (picked != null) setState(() => _timeStart = picked);
  }

  Future<void> _pickTimeEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeEnd,
    );
    if (picked != null) setState(() => _timeEnd = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final localDebut = DateTime(
      _date.year, _date.month, _date.day,
      _timeStart.hour, _timeStart.minute,
    );
    final localFin = DateTime(
      _date.year, _date.month, _date.day,
      _timeEnd.hour, _timeEnd.minute,
    );
    if (localFin.isBefore(localDebut)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La date de fin doit être après la date de début')),
      );
      return;
    }

    final dtDebutUtc = localDebut.toUtc();
    final dtFinUtc   = localFin.toUtc();
    final ev = EventModel(
      id: widget.initial?.id ?? 0,
      titre: _titreCtl.text.trim(),
      description: _descCtl.text.trim(),
      dateDebut: dtDebutUtc,
      dateFin: dtFinUtc,
      dateDebutAffiche: DateFormat.yMMMd().add_Hm().format(localDebut),
      dateFinAffiche: DateFormat.yMMMd().add_Hm().format(localFin),
      createur: widget.initial?.createur,
    );

    await widget.onSubmit(ev);
  }

  @override
  Widget build(BuildContext context) {
    final fmtDate = DateFormat.yMMMMd().format(_date);
    final fmtStart = _timeStart.format(context);
    final fmtEnd = _timeEnd.format(context);

    InputDecoration _dec(String label, [IconData? icon]) => InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: Color(0xFF2196F3)) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Titre
          TextFormField(
            controller: _titreCtl,
            decoration: _dec('Titre', Icons.title),
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descCtl,
            decoration: _dec('Description', Icons.description),
            minLines: 2,
            maxLines: 4,
            validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 24),

          // Sélecteurs date & heure
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_outlined),
                  label: Text(fmtDate, style: GoogleFonts.poppins()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTimeStart,
                  icon: const Icon(Icons.access_time_outlined),
                  label: Text('Début: $fmtStart', style: GoogleFonts.poppins()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickTimeEnd,
                  icon: const Icon(Icons.access_time),
                  label: Text('Fin: $fmtEnd', style: GoogleFonts.poppins()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Bouton envoyer
          ElevatedButton(
            onPressed: _handleSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              widget.initial == null ? 'Créer' : 'Enregistrer',
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

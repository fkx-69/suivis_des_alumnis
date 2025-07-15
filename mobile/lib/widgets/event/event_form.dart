import 'dart:io';
import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';

typedef EventFormSubmit = Future<void> Function(EventModel event, File? image);

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

class _EventFormState extends State<EventForm> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titreCtl;
  late TextEditingController _descCtl;
  late DateTime _date;
  late TimeOfDay _timeStart;
  late TimeOfDay _timeEnd;
  File? _imageFile;
  bool _isSubmitting = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
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
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _titreCtl.dispose();
    _descCtl.dispose();
    _fadeController.dispose();
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
          colorScheme: ColorScheme.light(
            primary: AppTheme.accentColor,
            onPrimary: Colors.white,
            onSurface: AppTheme.primaryColor,
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
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.accentColor,
            onPrimary: Colors.white,
            onSurface: AppTheme.primaryColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _timeStart = picked);
  }

  Future<void> _pickTimeEnd() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeEnd,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppTheme.accentColor,
            onPrimary: Colors.white,
            onSurface: AppTheme.primaryColor,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _timeEnd = picked);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

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
        SnackBar(
          backgroundColor: AppTheme.errorColor,
          content: Text(
            'La date de fin doit être après la date de début',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
      setState(() => _isSubmitting = false);
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

    await widget.onSubmit(ev, _imageFile);
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final fmtDate = DateFormat.yMMMMd().format(_date);
    final fmtStart = _timeStart.format(context);
    final fmtEnd = _timeEnd.format(context);

    InputDecoration _dec(String label, [IconData? icon]) => InputDecoration(
      labelText: label,
      labelStyle: textTheme.bodyMedium?.copyWith(
        color: AppTheme.subTextColor,
      ),
      prefixIcon: icon != null ? Icon(icon, color: colorScheme.secondary) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.secondary, width: 2),
      ),
      filled: true,
      fillColor: AppTheme.surfaceColor,
    );

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Titre
            TextFormField(
              controller: _titreCtl,
              decoration: _dec('Titre de l\'événement', Icons.title),
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.primaryColor,
              ),
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 20),

            // Description
            TextFormField(
              controller: _descCtl,
              decoration: _dec('Description', Icons.description),
              style: textTheme.bodyLarge?.copyWith(
                color: AppTheme.primaryColor,
              ),
              minLines: 3,
              maxLines: 5,
              validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 24),

            // Image Picker
            if (_imageFile != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.borderColor,
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(
                        _imageFile!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        onPressed: () => setState(() => _imageFile = null),
                      ),
                    ),
                  ],
                ),
              ),
            if (_imageFile == null) ...[
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: Icon(
                  Icons.add_photo_alternate,
                  color: colorScheme.secondary,
                  size: 20,
                ),
                label: Text(
                  'Ajouter une image (optionnel)',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: colorScheme.secondary,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Sélecteurs date & heure
            Text(
              'Date et heure',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.calendar_today_outlined,
                        color: colorScheme.secondary,
                        size: 20,
                      ),
                      title: Text(
                        fmtDate,
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: _pickDate,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.access_time_outlined,
                        color: colorScheme.secondary,
                        size: 20,
                      ),
                      title: Text(
                        'Début: $fmtStart',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: _pickTimeStart,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderColor,
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.access_time,
                        color: colorScheme.secondary,
                        size: 20,
                      ),
                      title: Text(
                        'Fin: $fmtEnd',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onTap: _pickTimeEnd,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Bouton envoyer
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Création en cours...',
                            style: textTheme.labelLarge?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        widget.initial == null ? 'Créer l\'événement' : 'Enregistrer',
                        style: textTheme.labelLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

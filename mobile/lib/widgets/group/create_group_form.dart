import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memoire/constants/app_theme.dart';

class CreateGroupForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final bool isLoading;
  final VoidCallback onSubmit;
  final void Function(File?) onPhotoSelected;

  const CreateGroupForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.descriptionController,
    required this.isLoading,
    required this.onSubmit,
    required this.onPhotoSelected,
  });

  @override
  State<CreateGroupForm> createState() => _CreateGroupFormState();
}

class _CreateGroupFormState extends State<CreateGroupForm> {
  File? _photo;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _photo = File(pickedFile.path));
      widget.onPhotoSelected(_photo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      elevation: theme.cardTheme.elevation,
      shape: theme.cardTheme.shape,
      color: theme.cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Créer un nouveau groupe',
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Champ sélection photo de profil
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.surfaceColor,
                    backgroundImage: _photo != null ? FileImage(_photo!) : null,
                    child: _photo == null
                        ? const Icon(Icons.add_a_photo, size: 30, color: AppTheme.subTextColor)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Photo de profil (optionnelle)',
                style: textTheme.bodySmall?.copyWith(color: AppTheme.subTextColor),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),
              TextFormField(
                controller: widget.nameController,
                decoration: const InputDecoration(labelText: 'Nom du groupe'),
                validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 2,
                maxLines: 4,
                validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: widget.isLoading ? null : widget.onSubmit,
                child: widget.isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
                    : const Text('Créer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:memoire/services/auth_service.dart';

class EditProfileAlumni extends StatefulWidget {
  @override
  _EditProfileAlumniState createState() => _EditProfileAlumniState();
}

class _EditProfileAlumniState extends State<EditProfileAlumni> {
  final _formKey = GlobalKey<FormState>();
  final controllers = <String, TextEditingController>{};
  bool isLoading = true;

  final Color mainBlue = Color(0xFF2196F3);

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    String accessToken = 'accessToken';
    final response = await AuthService.getUserInfo(accessToken);
    if (response['success']) {
      final data = response['data'];
      for (var key in data.keys) {
        controllers[key] = TextEditingController(text: data[key]?.toString() ?? '');
      }
      setState(() => isLoading = false);
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : ${response['message']}')),
      );
    }
  }

  Future<void> submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      final Map<String, String> updatedData = {};
      controllers.forEach((key, controller) {
        updatedData[key] = controller.text.trim();
      });
      String accessToken = 'accessToken';
      final response = await AuthService.updateUserInfo(
          accessToken: accessToken,
          updatedData: updatedData
      );
      setState(() => isLoading = false);
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil mis à jour avec succès.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : ${response['message']}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier mon profil'),
        backgroundColor: mainBlue,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: mainBlue))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ...controllers.entries.map((entry) => _buildField(entry.key, entry.value)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainBlue,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("Enregistrer", style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label.replaceAll('_', ' '),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (value) => value!.isEmpty ? 'Entrez $label' : null,
      ),
    );
  }
}

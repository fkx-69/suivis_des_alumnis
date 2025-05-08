import 'package:flutter/material.dart';
import 'package:memoire/services/auth_service.dart';

class RegisterAlumni extends StatefulWidget {
  @override
  _RegisterAlumniState createState() => _RegisterAlumniState();
}

class _RegisterAlumniState extends State<RegisterAlumni> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final passwordController = TextEditingController();
  final cycleController = TextEditingController();
  final secteur_activiteController = TextEditingController();
  final situation_proController = TextEditingController();
  final poste_actuelController = TextEditingController();
  final nom_entrepriseController = TextEditingController();
  bool isLoading = false;

  final Color mainBlue = Color(0xFF2196F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // fond blanc comme dans la maquette
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Inscription",
          style: TextStyle(color: mainBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: mainBlue),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputField("Email", emailController),
              _buildInputField("Nom d'utilisateur", usernameController),
              _buildInputField("Nom", nomController),
              _buildInputField("Prénom", prenomController),
              _buildInputField("Mot de passe", passwordController, isPassword: true),
              _buildInputField("Date fin de cycle", cycleController),
              _buildInputField("Secteur d'activité", secteur_activiteController),
              _buildInputField("Situation professionnelle", situation_proController),
              _buildInputField("Poste actuel", poste_actuelController),
              _buildInputField("Nom d'entreprise", nom_entrepriseController),
              SizedBox(height: 30),
              isLoading
                  ? Center(child: CircularProgressIndicator(color: mainBlue))
                  : SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });

                      final response = await AuthService.registerAlumni(
                        email: emailController.text,
                        username: usernameController.text,
                        nom: nomController.text,
                        prenom: prenomController.text,
                        password: passwordController.text,
                        dateFinCycle: cycleController.text,
                        secteurActivite: secteur_activiteController.text,
                        situationPro: situation_proController.text,
                        posteActuel: poste_actuelController.text,
                        nomEntreprise: nom_entrepriseController.text,
                      );

                      setState(() {
                        isLoading = false;
                      });

                      if (response['success']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Inscription réussie!')),
                        );
                        Navigator.pushReplacementNamed(context, '/dashboard-alumni');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: ${response['message']}')),
                        );
                      }
                    }
                  },
                  child: Text("S'inscrire", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        validator: (value) => value!.isEmpty ? 'Entrez $label' : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[800]),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
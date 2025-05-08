import 'package:flutter/material.dart';
import 'package:memoire/services/auth_service.dart';

class RegisterStudent extends StatefulWidget {
  @override
  _RegisterStudentState createState() => _RegisterStudentState();
}

class _RegisterStudentState extends State<RegisterStudent> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final passwordController = TextEditingController();
  final filiereController = TextEditingController();
  final niveauController = TextEditingController();
  final anneeEntreeController = TextEditingController();
  bool isLoading = false;

  final Color mainBlue = Color(0xFF2196F3); // Couleur bleue de la maquette

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc comme sur la maquette
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "S'inscrire",
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField("Email", emailController),
              _buildInputField("Nom d'utilisateur", usernameController),
              _buildInputField("Nom", nomController),
              _buildInputField("Prénom", prenomController),
              _buildInputField("Mot de passe", passwordController, isPassword: true),
              _buildInputField("Filière", filiereController),
              _buildInputField("Niveau d'étude", niveauController),
              _buildInputField("Année d'entrée", anneeEntreeController),
              SizedBox(height: 30),
              isLoading
                  ? Center(child: CircularProgressIndicator(color: mainBlue))
                  : SizedBox(
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

                      final response = await AuthService.registerEtudiant(
                        email: emailController.text,
                        username: usernameController.text,
                        nom: nomController.text,
                        prenom: prenomController.text,
                        password: passwordController.text,
                        filiere: filiereController.text,
                        niveauEtude: niveauController.text,
                        anneeEntree: int.parse(anneeEntreeController.text),
                      );

                      setState(() {
                        isLoading = false;
                      });

                      if (response['success']) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Inscription réussie!')),
                        );
                        Navigator.pushReplacementNamed(context, '/login');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erreur: ${response['message']}')),
                        );
                      }
                    }
                  },
                  child: Text(
                    "S'inscrire",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
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
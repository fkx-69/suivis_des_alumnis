import 'package:flutter/material.dart';
import 'package:suivi_alumni/services/auth_service.dart';

class RegisterStudent extends StatefulWidget{
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Etudiant Inscription")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) =>
                value!.isEmpty ? 'Entrez votre email' : null,
              ),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(labelText: "Nom d'utilisateur"),
                validator: (value) =>
                value!.isEmpty ? "Entrez votre nom d'utilisateur" : null,
              ),
              TextFormField(
                controller: nomController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) =>
                value!.isEmpty ? 'Entrez votre nom' : null,
              ),
              TextFormField(
                controller: prenomController,
                decoration: InputDecoration(labelText: 'Prénom'),
                validator: (value) =>
                value!.isEmpty ? 'Entrez votre prénom' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                validator: (value) =>
                value!.isEmpty ? 'Entrez votre mot de passe' : null,
              ),
              TextFormField(
                controller: filiereController,
                decoration: InputDecoration(labelText: 'Filière'),
                validator: (value) =>
                value!.isEmpty ? 'Entrez votre filière' : null,
              ),
              TextFormField(
                controller: niveauController,
                decoration: InputDecoration(labelText: "Niveau d'étude"),
                validator: (value) =>
                value!.isEmpty ? "Entrez votre niveau d'étude" : null,
              ),
              TextFormField(
                controller: anneeEntreeController,
                decoration: InputDecoration(labelText: 'Mentor'),
                validator: (value) =>
                value!.isEmpty ? 'Entrez votre mentor' : null,
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() { isLoading = true; });

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

                    setState(() { isLoading = false; });

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
                child: Text("S'inscrire"), // <-- il manquait ça
              )
            ]
              ),
            ),
          ),
        );
  }
}
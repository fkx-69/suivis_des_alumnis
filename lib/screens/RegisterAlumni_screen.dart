import 'package:flutter/material.dart';
import 'package:suivi_alumni/services/auth_service.dart';

class RegisterAlumni extends StatefulWidget{
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
  bool isLoading= true;

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
                controller: secteur_activiteController,
                decoration: InputDecoration(labelText: "Secteur d'activité"),
                validator: (value) =>
                value!.isEmpty ? "Entrez votre secteur d'activité" : null,
              ),
              TextFormField(
                controller: situation_proController,
                decoration: InputDecoration(
                    labelText: "Situation professionnelle"),
                validator: (value) =>
                value!.isEmpty
                    ? "Entrez votre situation professionnelle"
                    : null,
              ),
              TextFormField(
                controller: poste_actuelController,
                decoration: InputDecoration(labelText: 'Poste actuel'),
              ),
              TextFormField(
                controller: nom_entrepriseController,
                decoration: InputDecoration(labelText: "Nom d'entreprise"),
              ),
              SizedBox(height: 20),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() { isLoading = true; });

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
                child: Text("S'inscrire"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
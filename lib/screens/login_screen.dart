import 'package:flutter/material.dart';
import 'package:suivi_alumni/services/auth_service.dart';

class LoginScreen extends StatefulWidget{
  @override
  _LoginScreenState createState() => _LoginScreenState();
  }

class _LoginScreenState extends State<LoginScreen>{
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Connexion')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) =>
                value!.isEmpty ? 'Entrez un email' : null,
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) =>
                value!.length < 8 ? 'Minimum 8 caractères' : null,
              ),
              SizedBox(height: 20),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading= true;
                        });
                        final response= await AuthService.login(
                            emailController.text,
                            passwordController.text
                        );
                        setState(() {
                          isLoading= false;
                        });
                        if (response['success']){
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Connexion réussie'))
                          );
                          Navigator.pushReplacementNamed(context, '/home');
                        } else{
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: ${response['message']}')),
                          );
                        }
                      }
                    },
                    child: Text('Se connecter'),
                  )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Bienvenue sur AlumniFy", style: TextStyle(fontSize: 32)),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text("Se connecter")
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text("S'inscrire")
            ),
          ],
        ),
      ),
    );
  }
}
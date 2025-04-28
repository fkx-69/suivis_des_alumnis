import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Inscription")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: ()=> Navigator.pushNamed(context, '/register-student'),
                child: Text("Etudiant"),
            ),
            ElevatedButton(
                onPressed: ()=>Navigator.pushNamed(context, '/register-alumni'),
                child: Text("Alumni"),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:suivi_alumni/screens/RegisterAlumni_screen.dart';
import 'package:suivi_alumni/screens/RegisterStudent_screen.dart';
import 'package:suivi_alumni/screens/login_screen.dart';
import 'package:suivi_alumni/screens/register_screen.dart';
import 'package:suivi_alumni/screens/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlumniFy',
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/login':(context)=> LoginScreen(),
        '/register':(context)=> RegisterScreen(),
        '/register-student':(context)=> RegisterStudent(),
        '/register-alumni':(context)=> RegisterAlumni(),
      },
    );
  }
}
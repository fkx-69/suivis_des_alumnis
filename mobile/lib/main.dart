import 'package:flutter/material.dart';
import 'package:memoire/screens/alumni/DashboardAlumni_screen.dart';
import 'package:memoire/screens/alumni/EditAlumniProfile_screen.dart';
import 'package:memoire/screens/alumni/ProfilAlumni_screen.dart';
import 'package:memoire/screens/alumni/RegisterAlumni_screen.dart';
import 'package:memoire/screens/student/RegisterStudent_screen.dart';
import 'package:memoire/screens/login_screen.dart';
import 'package:memoire/screens/register_screen.dart';
import 'package:memoire/screens/welcome_screen.dart';

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
        '/dashboard-alumni':(context)=> DashboardPage(),
        '/profil-alumni':(context)=> ProfileAlumni(),
        '/edit-profil-alumni':(context)=> EditProfileAlumni(),
      },
    );
  }
}
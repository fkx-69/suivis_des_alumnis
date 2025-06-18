import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memoire/screens/auth/home_screen.dart';


void main() {
  runApp(const AlumniApp());
}

class AlumniApp extends StatelessWidget {
  const AlumniApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlumniFy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

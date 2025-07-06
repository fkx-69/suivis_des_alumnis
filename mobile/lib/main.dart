import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:memoire/screens/auth/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Nécessaire avant toute opération async
  await initializeDateFormatting('fr_FR', null); // Initialise les formats pour 'fr_FR'

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
      home: const WelcomeScreen(),
    );
  }
}

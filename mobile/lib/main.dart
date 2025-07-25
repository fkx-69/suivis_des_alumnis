import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/app_theme.dart'; // Chemin à adapter selon ton arborescence
import 'screens/auth/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  runApp(const AlumniApp());
}

class AlumniApp extends StatelessWidget {
  const AlumniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AlumniFy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // 🔁 Utilise le thème global ITMA
      home: const WelcomeScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'constants/app_theme.dart'; // Chemin à adapter selon ton arborescence
import 'screens/auth/welcome_screen.dart';
import 'services/event_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  runApp(const AlumniApp());
}

class AlumniApp extends StatelessWidget {
  const AlumniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = EventProvider();
            // Charger les événements au démarrage
            WidgetsBinding.instance.addPostFrameCallback((_) {
              provider.loadAllEvents();
            });
            return provider;
          },
        ),
      ],
      child: MaterialApp(
        title: 'AlumniFy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme, // 🔁 Utilise le thème global ITMA
        home: const WelcomeScreen(),
      ),
    );
  }
}

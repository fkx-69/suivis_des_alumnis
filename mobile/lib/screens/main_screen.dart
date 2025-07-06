import 'package:flutter/material.dart';
import 'package:memoire/screens/event/events_main_screen.dart';
import 'package:memoire/home_screen.dart';
import 'package:memoire/screens/messaging/conversations_main_screen.dart';
import 'package:memoire/screens/profile/profile_screen.dart';
import 'package:memoire/screens/stat/statistique_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    EventsMainScreen(),
    ConversationsMainScreen(),
    StatistiquesScreen(),
    ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
    BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Évènements'),
    BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
    BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

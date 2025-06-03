import 'package:flutter/material.dart';
import 'package:memoire/widgets/app_bottom_nav_bar.dart';
import 'package:memoire/screens/auth/home_screen.dart';
import 'package:memoire/screens/event/event_list_screen.dart';

import 'package:memoire/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  static const List<Widget> _pages = [
    HomeScreen(),           // 0 = Accueil
    EventListScreen(),      // 1 = Événements
    //MessageListScreen(),    // 2 = Messages
    ProfileScreen(),        // 3 = Profil
  ];

  void _onNavTap(int idx) {
    if (idx == _selectedIndex) return;
    setState(() {
      _selectedIndex = idx;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // on peut laisser un AppBar ou en mettre un par page individuellement
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}

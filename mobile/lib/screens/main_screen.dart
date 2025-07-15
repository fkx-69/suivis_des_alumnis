import 'package:flutter/material.dart';
import 'package:memoire/constants/app_theme.dart';
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

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = const [
    HomeScreen(),
    EventsMainScreen(),
    ConversationsMainScreen(),
    StatistiquesScreen(),
    ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Accueil',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.event_outlined),
      activeIcon: Icon(Icons.event),
      label: 'Évènements',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.message_outlined),
      activeIcon: Icon(Icons.message),
      label: 'Messages',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.bar_chart_outlined),
      activeIcon: Icon(Icons.bar_chart),
      label: 'Stats',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Profil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _fadeController.reset();
    _fadeController.forward();
  }

  IconData getIconData(Widget? widget) {
    if (widget is Icon && widget.icon != null) {
      return widget.icon!;
    }
    return Icons.help_outline; // fallback
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          border: Border(
            top: BorderSide(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                _navItems.length,
                    (index) => Expanded(
                      child: _buildNavItem(index),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;
    final item = _navItems[index];

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondary.withAlpha(25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              getIconData(isSelected ? item.activeIcon : item.icon),
              color: isSelected
                  ? theme.colorScheme.secondary
                  : AppTheme.subTextColor,
              size: 18,
            ),
            const SizedBox(height: 1),
            Flexible(
              child: Text(
                item.label!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.secondary
                      : AppTheme.subTextColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 9,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

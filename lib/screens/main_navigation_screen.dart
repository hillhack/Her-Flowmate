import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'log_period_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    HomeScreen(),
    CalendarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true, // Allows body to go behind bottom bar
      body: _screens[_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 30),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LogPeriodScreen()),
            );
          },
          tooltip: 'Log Period',
          elevation: 0,
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.home_rounded, 0, theme),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(Icons.calendar_month_rounded, 1, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, ThemeData theme) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          size: 28,
          color: isSelected ? theme.colorScheme.primary : Colors.grey.shade400,
        ),
      ),
    );
  }
}

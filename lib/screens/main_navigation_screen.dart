import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'log_period_screen.dart';
import 'daily_checkin_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/shared_drawer.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      HapticFeedback.lightImpact();
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      extendBody: true, // Crucial for floating bar
      drawer: const SharedDrawer(),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 80,
            decoration: AppTheme.glassDecoration(radius: 32, opacity: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bottomNavItem(0, Icons.home_rounded, 'Home'),
                _bottomNavItem(1, Icons.calendar_month_rounded, 'Calendar'),
                _logButton(),
                _bottomNavItem(2, Icons.person_rounded, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(
      begin: 1.0,
      duration: 800.ms,
      curve: Curves.easeOutCubic,
    );
  }

  Widget _logButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withValues(alpha: 0.2),
          builder: (context) => _buildAddMenu(context),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: AppTheme.brandGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.roseGold.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
      ),
    );
  }

  Widget _bottomNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onItemTapped(index),
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                  icon,
                  color:
                      isSelected ? AppTheme.accentPink : AppTheme.textSecondary,
                  size: 26,
                )
                .animate(target: isSelected ? 1 : 0)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  duration: 300.ms,
                ),
            const SizedBox(height: 4),
            if (isSelected)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.accentPink,
                  shape: BoxShape.circle,
                ),
              ).animate().scale(duration: 200.ms, curve: Curves.elasticOut),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMenu(BuildContext context) {
    final storage = context.read<StorageService>();
    final isPregnant = storage.userGoal == 'pregnant';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(
            alpha: 0.95,
          ), // High opacity for stability
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              if (isPregnant) ...[
                _menuItem(
                  '📝',
                  'Daily Check-in',
                  'Log symptoms and moods',
                  0,
                  () => _openSheet(const DailyCheckinScreen()),
                ),
                const SizedBox(height: 12),
                _menuItem(
                  '👣',
                  'Kick Counter',
                  'Track baby\'s movements',
                  1,
                  () => _showComingSoon(context, 'Kick Counter'),
                ),
                const SizedBox(height: 12),
                _menuItem(
                  '⚖️',
                  'Weight Log',
                  'Track your pregnancy weight',
                  2,
                  () => _showComingSoon(context, 'Weight Log'),
                ),
              ] else ...[
                _menuItem(
                  '🩸',
                  'Log Period',
                  'Track your cycle start/end',
                  0,
                  () => _openSheet(const LogPeriodScreen()),
                ),
                const SizedBox(height: 16),
                _menuItem(
                  '📝',
                  'Daily Check-in',
                  'Log symptoms and moods',
                  1,
                  () => _openSheet(const DailyCheckinScreen()),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon! 🚀'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openSheet(Widget screen) {
    Navigator.pop(context);
    Future.delayed(200.ms, () {
      if (mounted) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => screen,
        );
      }
    });
  }

  Widget _menuItem(
    String emoji,
    String title,
    String sub,
    int idx,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecoration(radius: 24, opacity: 0.4),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (idx * 100).ms).slideY(begin: 0.2);
  }
}

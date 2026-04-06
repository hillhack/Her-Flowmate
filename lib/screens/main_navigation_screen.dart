import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'log_period_screen.dart';
import 'daily_checkin_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'wellness_reminders_screen.dart';
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
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          _onItemTapped(0);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.frameColor,
        extendBody: true, // Crucial for floating bar
        drawer: const SharedDrawer(),
        body: Container(
          decoration: AppTheme.getBackgroundDecoration(context),
          child: IndexedStack(index: _selectedIndex, children: _screens),
        ),
        floatingActionButton: _logButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 80, 16), // Space for FAB
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Container(
            height: 64,
            decoration: AppTheme.glassDecoration(radius: 28, opacity: 0.08),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(child: _bottomNavItem(0, Icons.home_rounded, 'Home')),
                Expanded(
                  child: _bottomNavItem(
                    1,
                    Icons.calendar_month_rounded,
                    'Calendar',
                  ),
                ),
                Expanded(
                  child: _bottomNavItem(2, Icons.person_rounded, 'Profile'),
                ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
      child: Semantics(
        label: 'Log dynamic health data',
        button: true,
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              barrierColor: Colors.black.withValues(alpha: 0.2),
              builder: (context) => _buildAddMenu(context),
            );
          },
          elevation: 8,
          backgroundColor: Colors.transparent,
          splashColor: Colors.white24,
          shape: const CircleBorder(),
          // Use Ink to ensure gradient fills the FAB and splash matches shape
          child: Ink(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              gradient: AppTheme.brandGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_rounded, size: 32, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _bottomNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onItemTapped(index),
      child: Semantics(
        label: '$label Tab',
        selected: isSelected,
        button: true,
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (isSelected)
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.accentPink.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                    ).animate().scale(
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                  Icon(
                        icon,
                        color:
                            isSelected
                                ? AppTheme.accentPink
                                : AppTheme.textSecondary,
                        size: 26,
                      )
                      .animate(target: isSelected ? 1 : 0)
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.2, 1.2),
                        duration: 300.ms,
                      )
                      .shimmer(
                        delay: 400.ms,
                        duration: 1200.ms,
                        color: Colors.white24,
                      ),
                ],
              ),
              const SizedBox(height: 5),
              if (isSelected)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentPink,
                    shape: BoxShape.circle,
                  ),
                ).animate().scale(duration: 200.ms, curve: Curves.elasticOut),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddMenu(BuildContext context) {
    final storage = context.read<StorageService>();
    final isPregnant = storage.userGoal == 'pregnant';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: Container(
        decoration: BoxDecoration(
          color:
              isDark
                  ? AppTheme.darkSurface.withValues(alpha: 0.9)
                  : Colors.white.withValues(
                    alpha: 0.95,
                  ), // High opacity for stability
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.white,
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 8,
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
                  '🧘',
                  'Wellness Goals',
                  'Manage your wellness',
                  1,
                  () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WellnessRemindersScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _menuItem(
                  '👣',
                  'Kick Counter',
                  'Track baby\'s movements',
                  2,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      color:
                          isDark ? AppTheme.darkTextPrimary : AppTheme.textDark,
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

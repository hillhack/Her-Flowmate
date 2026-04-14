import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import 'wellness_reminders_screen.dart';
import 'insights_screen.dart';
import 'log_period_screen.dart';
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
  final PageController _pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      CalendarScreen(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      InsightsScreen(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      WellnessRemindersScreen(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
      ProfileScreen(onMenuPressed: () => _scaffoldKey.currentState?.openDrawer()),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      HapticFeedback.lightImpact();
      setState(() => _selectedIndex = index);
      _pageController.jumpToPage(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          _onItemTapped(0);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppTheme.frameColor,
        extendBody: true, // Crucial for floating bar
        drawer: const SharedDrawer(),
        body: Container(
          decoration: AppTheme.getBackgroundDecoration(context),
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
          ),
        ),
        floatingActionButton:
            context.select<StorageService, bool>(
                  (storage) => storage.userGoal == 'pregnant',
                )
                ? null
                : _logButton(),
        floatingActionButtonLocation:
            isTablet
                ? FloatingActionButtonLocation.endFloat
                : FloatingActionButtonLocation.endFloat,
        bottomNavigationBar: _buildBottomBar(isTablet),
      ),
    );
  }

  Widget _buildBottomBar(bool isTablet) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppResponsive.pad(context),
          0,
          AppResponsive.pad(context),
          bottomPadding + AppDesignTokens.space12,
        ),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: isDark 
                ? AppTheme.darkSurface.withValues(alpha: 0.9) 
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: isDark 
                  ? Colors.white12 
                  : AppTheme.accentPink.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(36),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: _bottomNavItem(0, Icons.home_rounded, 'Dashboard')),
                    Expanded(child: _bottomNavItem(1, Icons.calendar_month_rounded, 'Calendar')),
                    Expanded(child: _bottomNavItem(2, Icons.bar_chart_rounded, 'Insights')),
                    Expanded(child: _bottomNavItem(3, Icons.notifications_rounded, 'Focus')),
                    Expanded(child: _bottomNavItem(4, Icons.person_rounded, 'You')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(
          begin: 0.5,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _logButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0, right: 12.0),
      child: Semantics(
        label: 'Add New Record',
        button: true,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentPink.withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showAddMenu(context);
            },
            elevation: 0,
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: const BoxDecoration(
                gradient: AppTheme.brandGradient,
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 56,
                height: 56,
                child: Icon(Icons.add_rounded, size: 32, color: Colors.white),
              ),
            ),
          ),
        ),
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textSecondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Add',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            _buildAddOption(
              context,
              icon: Icons.calendar_today_rounded,
              title: 'Log Period',
              subtitle: 'Update your cycle status',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogPeriodScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildAddOption(
              context,
              icon: Icons.spa_rounded,
              title: 'Add Wellness Goal',
              subtitle: 'Meditation, yoga, sleep and more',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WellnessRemindersScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAddOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.accentPink.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accentPink.withValues(alpha: 0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentPink.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.accentPink, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _onItemTapped(index),
      child: Semantics(
        label: '$label Tab',
        selected: isSelected,
        button: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: 300.ms,
              curve: Curves.easeOut,
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.accentPink
                    : (isDark ? AppTheme.darkOnSurface.withValues(alpha: 0.4) : AppTheme.textSecondary.withValues(alpha: 0.6)),
                size: isSelected ? 26 : 24,
              ),
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
              ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack)
            else
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.darkOnSurface.withValues(alpha: 0.3) : AppTheme.textSecondary.withValues(alpha: 0.5),
                ),
                maxLines: 1,
              ),
          ],
        ),
      ),
    );
  }
}

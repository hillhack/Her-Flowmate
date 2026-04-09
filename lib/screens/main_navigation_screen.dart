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
import 'insights_screen.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/common/neu_card.dart';
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

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    CalendarScreen(),
    InsightsScreen(),
    WellnessRemindersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
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

    // Check if pregnant to determine if we need space for FAB
    // Although we use endFloat now so it floats above the bar,
    // let's adjust padding cleanly.
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppResponsive.pad(context),
          0,
          AppResponsive.pad(context),
          bottomPadding + AppDesignTokens.space16,
        ),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: AppTheme.accentPink.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: AppTheme.accentPink.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
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
                  child: _bottomNavItem(2, Icons.bar_chart_rounded, 'Insights'),
                ),
                Expanded(
                  child: _bottomNavItem(
                    3,
                    Icons.notifications_rounded,
                    'Reminders',
                  ),
                ),
                Expanded(
                  child: _bottomNavItem(4, Icons.person_rounded, 'Profile'),
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
        label: 'Open quick actions menu',
        button: true,
        child: FloatingActionButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              barrierColor: Colors.black.withValues(alpha: 0.5),
              builder: (context) => _buildAddMenu(context),
            );
          },
          elevation: 4,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (isSelected)
                  Container(
                    width: 38,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.accentPink.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(14),
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
                              : AppTheme.textSecondary.withValues(alpha: 0.7),
                      size: 22,
                    )
                    .animate(target: isSelected ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 300.ms,
                    ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected
                        ? AppTheme.accentPink
                        : AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMenu(BuildContext context) {
    final storage = context.read<StorageService>();
    final isPregnant = storage.userGoal == 'pregnant';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
          child: Container(
            decoration: BoxDecoration(
              color:
                  isDark
                      ? AppTheme.darkSurface.withValues(alpha: 0.95)
                      : Colors.white.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
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
                      onTap: () => _openSheet(const DailyCheckinScreen()),
                    ),
                    const SizedBox(height: 12),
                    _menuItem(
                      '🧘',
                      'Wellness Goals',
                      'Manage your wellness',
                      1,
                      onTap: () {
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
                      isSoon: true,
                    ),
                    const SizedBox(height: 12),
                    _menuItem(
                      '⚖️',
                      'Weight Log',
                      'Track your pregnancy weight',
                      3,
                      isSoon: true,
                    ),
                  ] else ...[
                    _menuItem(
                      '🩸',
                      'Log Period',
                      'Track your cycle start/end',
                      0,
                      onTap: () => _openSheet(const LogPeriodScreen()),
                    ),
                    const SizedBox(height: 16),
                    _menuItem(
                      '📝',
                      'Daily Check-in',
                      'Log symptoms and moods',
                      1,
                      onTap: () => _openSheet(const DailyCheckinScreen()),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openSheet(Widget screen) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => screen,
    );
  }

  Widget _menuItem(
    String emoji,
    String title,
    String sub,
    int idx, {
    VoidCallback? onTap,
    bool isSoon = false,
  }) {
    final content = NeumorphicCard(
      padding: const EdgeInsets.all(AppDesignTokens.space20),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppDesignTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: AppDesignTokens.bodyLargeSize,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                          decoration:
                              isSoon ? TextDecoration.lineThrough : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSoon) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPink.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Soon',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentPink,
                          ),
                        ),
                      ),
                    ],
                  ],
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
          if (!isSoon)
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.textSecondary,
            ),
        ],
      ),
    );

    return Semantics(
          label: 'Log $title',
          button: true,
          child: GestureDetector(
            onTap: () {
              if (!isSoon && onTap != null) {
                HapticFeedback.selectionClick();
                onTap();
              }
            },
            child: content,
          ),
        )
        .animate(key: ValueKey(title))
        .fadeIn(delay: (idx * 100).ms)
        .slideY(begin: 0.2);
  }
}

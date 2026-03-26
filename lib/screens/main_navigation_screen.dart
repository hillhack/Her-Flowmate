import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/brand_widgets.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'log_period_screen.dart';
import 'daily_checkin_screen.dart';
import 'calendar_screen.dart';
import 'history_screen.dart';
import 'education_hub_screen.dart';
import 'profile_screen.dart';
import 'partner_sync_screen.dart';
import 'mode_settings_screen.dart';
import 'feedback_screen.dart';
import '../widgets/neu_container.dart';
import '../widgets/period_health_widgets.dart';

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

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      drawer: _buildDrawer(context, storage),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: IndexedStack(index: _selectedIndex, children: _screens),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: NeuContainer(
        height: 72,
        radius: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        style: NeuStyle.convex,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomNavItem(0, Icons.home_rounded, 'Home'),
            _bottomNavItem(1, Icons.calendar_month_rounded, 'Calendar'),
            _logButton(),
            _bottomNavItem(2, Icons.person_rounded, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _logButton() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => _buildAddMenu(context),
        );
      },
      child: NeuContainer(
        width: 48,
        height: 48,
        radius: 24,
        style: NeuStyle.convex,
        child: const Icon(
          Icons.add_rounded,
          size: 28,
          color: AppTheme.accentPink,
        ),
      ),
    );
  }

  Widget _bottomNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: isSelected
            ? BoxDecoration(
                color: AppTheme.accentPink.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.accentPink : AppTheme.textSecondary,
              size: 24,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: AppTheme.accentPink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMenu(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.frameColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const LogPeriodScreen(),
                );
              },
              child: NeuContainer(
                padding: const EdgeInsets.all(20),
                radius: 24,
                child: Row(
                  children: [
                    const Text('🩸', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 16),
                    Text(
                      'Log Period',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().slideY(begin: 0.1, duration: 200.ms),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const DailyCheckinScreen(),
                );
              },
              child: NeuContainer(
                padding: const EdgeInsets.all(20),
                radius: 24,
                child: Row(
                  children: [
                    const Text('📝', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 16),
                    Text(
                      'Daily Check-in',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().slideY(begin: 0.1, delay: 100.ms, duration: 200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, StorageService storage) {
    final initial = storage.userName.isNotEmpty
        ? storage.userName[0].toUpperCase()
        : 'U';

    return Drawer(
      backgroundColor: AppTheme.frameColor,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            NeuContainer(
              width: 80,
              height: 80,
              radius: 40,
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.poppins(
                    color: AppTheme.accentPink,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              storage.userName.isNotEmpty ? storage.userName : 'Guest',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 48),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _actionDrawerItem(
                    icon: Icons.history_rounded,
                    title: 'History',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _actionDrawerItem(
                    icon: Icons.menu_book_rounded,
                    title: 'Cycle Guide',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EducationHubScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  _actionDrawerItem(
                    icon: Icons.favorite_rounded,
                    title: 'Partner Sync',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PartnerSyncScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _actionDrawerItem(
                    icon: Icons.health_and_safety_rounded,
                    title: 'Period Health',
                    onTap: () {
                      _showPeriodHealthModal(context);
                    },
                  ),

                  const SizedBox(height: 24),
                  Divider(color: AppTheme.shadowDark.withOpacity(0.3)),
                  const SizedBox(height: 24),

                  _actionDrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'Settings',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ModeSettingsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _actionDrawerItem(
                    icon: Icons.help_outline_rounded,
                    title: 'Help',
                    onTap: () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppTheme.bgColor,
                        title: const Text('Help'),
                        content: Text.rich(
                          TextSpan(
                            children: [
                              const WidgetSpan(child: BrandName(fontSize: 16)),
                              const TextSpan(
                                text:
                                    ' is your gentle cycle companion. Tap the ⓘ icons to learn more about each section.',
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Got it'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _actionDrawerItem(
                    icon: Icons.contact_support_rounded,
                    title: 'Contact Support',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8,
              ),
              child: _actionDrawerItem(
                icon: Icons.logout_rounded,
                title: 'Logout',
                onTap: () async {
                  await storage.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BrandName(fontSize: 14),
                  Text(
                    ' v1.2.0',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodHealthModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PeriodHealthModal(),
    );
  }

  Widget _actionDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return NeuContainer(
      margin: const EdgeInsets.only(bottom: 8),
      radius: 20,
      onTap: () {
        Navigator.pop(context); // Always close drawer on action
        onTap();
      },
      child: ListTile(
        leading: Icon(icon, color: AppTheme.accentPink, size: 24),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: AppTheme.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
} // Correctly close the _MainNavigationScreenState class

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'insights_screen.dart';
import 'log_period_screen.dart';
import 'calendar_screen.dart';
import 'feedback_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'mode_settings_screen.dart';
import '../widgets/notification_widgets.dart';
import '../widgets/glass_container.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    InsightsScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      drawer: _buildDrawer(context, storage),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: GlassContainer(
              padding: const EdgeInsets.all(8),
              radius: 12,
              child: const Icon(Icons.menu_rounded, color: AppTheme.textDark),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'HerFlowmate',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            letterSpacing: -0.5,
          ),
        ),
        actions: const [
          NotificationBell(),
          SizedBox(width: 12),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: _screens[_selectedIndex],
      ),
      floatingActionButton: (_selectedIndex == 0 && storage.userGoal != 'pregnant')
          ? GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const LogPeriodScreen(),
                );
              },
              child: GlassContainer(
                width: 64,
                height: 64,
                radius: 32,
                child: const Icon(Icons.add_rounded, size: 32, color: AppTheme.accentPink),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack)
          : null,
    );
  }

  Widget _buildDrawer(BuildContext context, StorageService storage) {
    final initial = storage.userName.isNotEmpty ? storage.userName[0].toUpperCase() : 'U';

    return Drawer(
      backgroundColor: AppTheme.frameColor,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            GlassContainer(
              width: 80, height: 80,
              radius: 40,
              child: Center(
                child: Text(
                  initial,
                  style: GoogleFonts.poppins(color: AppTheme.accentPink, fontWeight: FontWeight.bold, fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              storage.userName.isNotEmpty ? storage.userName : 'Guest',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
            ),
            const SizedBox(height: 48),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _drawerItem(icon: Icons.home_rounded, title: 'Home', index: 0),
                  const SizedBox(height: 12),
                  _actionDrawerItem(
                    icon: Icons.calendar_month_rounded, 
                    title: 'Calendar', 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CalendarScreen()))
                  ),
                  const SizedBox(height: 12),
                  _drawerItem(icon: Icons.lightbulb_rounded, title: 'Insights', index: 1),
                  const SizedBox(height: 12),
                  _drawerItem(icon: Icons.history_rounded, title: 'History', index: 2),
                  
                  const SizedBox(height: 24),
                  Divider(color: AppTheme.shadowDark.withOpacity(0.3)),
                  const SizedBox(height: 24),

                  _actionDrawerItem(
                    icon: Icons.settings_rounded, 
                    title: 'Settings', 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ModeSettingsScreen()))
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
                        content: const Text('HerFlowmate is your gentle cycle companion. Tap the ⓘ icons to learn more about each section.'),
                        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it'))],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _actionDrawerItem(
                    icon: Icons.contact_support_rounded, 
                    title: 'Contact Support', 
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen()))
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
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
                }
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Text(
                'HerFlowmate v1.0',
                style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionDrawerItem({required IconData icon, required String title, required VoidCallback onTap}) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      radius: 20,
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: ListTile(
        leading: Icon(icon, color: AppTheme.accentPink, size: 24),
        title: Text(title, style: GoogleFonts.inter(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _drawerItem({required IconData icon, required String title, required int index}) {
    final isSelected = _selectedIndex == index;
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      radius: 20,
      opacity: isSelected ? 0.2 : AppTheme.glassOpacity,
      borderColor: isSelected ? AppTheme.accentPink.withOpacity(0.5) : Colors.white.withOpacity(0.3),
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
      child: ListTile(
        leading: Icon(icon, color: isSelected ? AppTheme.accentPink : AppTheme.textSecondary),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: isSelected ? AppTheme.accentPink : AppTheme.textDark,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

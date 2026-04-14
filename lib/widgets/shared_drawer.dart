import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/period_health_widgets.dart';
import '../widgets/themed_container.dart';
import '../screens/history_screen.dart';
import '../screens/education_hub_screen.dart';
import '../screens/partner_sync_screen.dart';
import '../screens/mode_settings_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/login_screen.dart';
import '../screens/community_screen.dart';
import '../screens/about_screen.dart';

class SharedDrawer extends StatelessWidget {
  const SharedDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();

    return Drawer(
      backgroundColor: context.surface,
      elevation: 0,
      width: context.screenWidth(context) * 0.82,
      child: Column(
        children: [
          _buildHeader(context, storage),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignTokens.space16,
                vertical: AppDesignTokens.space24,
              ),
              children: [
                _drawerSectionTitle(context, 'MY HEALTH'),
                _menuItem(
                  context,
                  icon: Icons.history_rounded,
                  title: 'Cycle History',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      ),
                ),
                _menuItem(
                  context,
                  icon: Icons.health_and_safety_rounded,
                  title: 'Period Health',
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const PeriodHealthModal(),
                    );
                  },
                ),
                const SizedBox(height: AppDesignTokens.space24),
                _drawerSectionTitle(context, 'RESOURCES'),
                _menuItem(
                  context,
                  icon: Icons.menu_book_rounded,
                  title: 'Cycle Guide',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EducationHubScreen()),
                      ),
                ),
                _menuItem(
                  context,
                  icon: Icons.forum_rounded,
                  title: 'Community Space',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CommunityScreen()),
                      ),
                ),
                _menuItem(
                  context,
                  icon: Icons.favorite_rounded,
                  title: 'Partner Sync',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PartnerSyncScreen()),
                      ),
                ),
                const SizedBox(height: AppDesignTokens.space24),
                _drawerSectionTitle(context, 'ACCOUNT'),
                _menuItem(
                  context,
                  icon: Icons.settings_rounded,
                  title: 'Settings',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ModeSettingsScreen(),
                        ),
                      ),
                ),
                _menuItem(
                  context,
                  icon: Icons.contact_support_rounded,
                  title: 'Feedback',
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                      ),
                ),
              ],
            ),
          ),
          _buildFooter(context, storage),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StorageService storage) {
    final avatarColor = context.isDarkMode ? context.primary : context.accent;
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 72, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.primary.withValues(alpha: 0.12),
            context.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ThemedContainer(
                type: ContainerType.neu,
                padding: EdgeInsets.zero,
                radius: 30,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.brandGradient,
                  ),
                  child: const Center(
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: AppDesignTokens.space16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      storage.userName.isEmpty ? 'Friend' : storage.userName,
                      style: AppTheme.playfair(
                        context: context,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: context.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ThemedContainer(
                      type: ContainerType.simple,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      radius: 10,
                      color: avatarColor.withValues(alpha: 0.1),
                      child: Text(
                        storage.userGoal.toUpperCase(),
                        style: AppTheme.outfit(
                          context: context,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: avatarColor,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _drawerSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDesignTokens.space12,
        bottom: AppDesignTokens.space12,
        top: AppDesignTokens.space12,
      ),
      child: Text(
        title,
        style: AppTheme.outfit(
          context: context,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: context.onSurface.withValues(alpha: 0.4),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      leading: Icon(icon, color: context.primary.withValues(alpha: 0.8), size: 24),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: context.onSurface.withValues(alpha: 0.9),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.onSurface.withValues(alpha: 0.15),
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDesignTokens.radiusSM),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildFooter(BuildContext context, StorageService storage) {
    return Container(
      padding: const EdgeInsets.all(AppDesignTokens.space24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.onSurface.withValues(alpha: 0.05)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            ListTile(
              onTap: () async {
                Navigator.pop(context);
                await storage.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              leading: Icon(
                Icons.logout_rounded,
                color: context.error.withValues(alpha: 0.7),
                size: 22,
              ),
              title: Text(
                'Logout',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.onSurface.withValues(alpha: 0.7),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(height: AppDesignTokens.space16),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutAppScreen()),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Her-Flowmate',
                    style: AppTheme.playfair(
                      context: context,
                      fontSize: 14,
                      color: context.onSurface.withValues(alpha: 0.3),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    ' v1.0.1',
                    style: AppTheme.outfit(
                      context: context,
                      fontSize: 12,
                      color: context.onSurface.withValues(alpha: 0.2),
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
}


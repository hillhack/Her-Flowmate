import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/brand_widgets.dart';
import '../widgets/neu_container.dart';
import '../widgets/period_health_widgets.dart';
import '../screens/history_screen.dart';
import '../screens/education_hub_screen.dart';
import '../screens/partner_sync_screen.dart';
import '../screens/mode_settings_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/login_screen.dart';

class SharedDrawer extends StatelessWidget {
  const SharedDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    return Drawer(
      backgroundColor: AppTheme.frameColor,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Center(child: BrandName(fontSize: 24)),
            const SizedBox(height: 48),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _actionDrawerItem(
                    context: context,
                    icon: Icons.history_rounded,
                    title: 'History',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScreen(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 12),
                  _actionDrawerItem(
                    context: context,
                    icon: Icons.menu_book_rounded,
                    title: 'Cycle Guide',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EducationHubScreen(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 12),
                  _actionDrawerItem(
                    context: context,
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
                    context: context,
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
                  const SizedBox(height: 24),
                  Divider(color: AppTheme.shadowDark.withValues(alpha: 0.3)),
                  const SizedBox(height: 24),
                  _actionDrawerItem(
                    context: context,
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
                  const SizedBox(height: 12),
                  _actionDrawerItem(
                    context: context,
                    icon: Icons.help_outline_rounded,
                    title: 'Help',
                    onTap:
                        () => showDialog(
                          context: context,
                          builder:
                              (ctx) => AlertDialog(
                                backgroundColor: AppTheme.bgColor,
                                title: const Text('Help'),
                                content: const Text.rich(
                                  TextSpan(
                                    children: [
                                      WidgetSpan(
                                        child: BrandName(fontSize: 16),
                                      ),
                                      TextSpan(
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
                    context: context,
                    icon: Icons.contact_support_rounded,
                    title: 'Contact Support',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeedbackScreen(),
                          ),
                        ),
                  ),
                  const SizedBox(height: 12),
                  _actionDrawerItem(
                    context: context,
                    icon: Icons.discord_rounded,
                    title: 'Join Community',
                    onTap: () => _launchDiscord(),
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
                context: context,
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

  void _launchDiscord() async {
    final Uri url = Uri.parse('https://discord.gg/aehkEXj8q');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch Discord URL');
    }
  }

  Widget _actionDrawerItem({
    required BuildContext context,
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
}

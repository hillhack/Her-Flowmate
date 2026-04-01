import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_theme.dart';
import '../widgets/neu_container.dart';
import '../widgets/brand_widgets.dart';
import 'feedback_screen.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Top Bar
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    NeuContainer(
                      padding: const EdgeInsets.all(10),
                      radius: 18,
                      style: NeuStyle.convex,
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.accentPink,
                        size: 22,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'About',
                          style: GoogleFonts.poppins(
                            color: AppTheme.midnightPlum,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Logo & Name
                      const BrandLogo(
                            size: 100,
                            showName: true,
                            nameFontSize: 30,
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(curve: Curves.easeOutBack),

                      const SizedBox(height: 12),
                      // Version
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentPink.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.accentPink.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          'Version 1.0.1 (Build 2)',
                          style: GoogleFonts.inter(
                            color: AppTheme.accentPink,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                      const SizedBox(height: 32),
                      // Description
                      NeuContainer(
                        radius: 28,
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Her-Flowmate is your gentle, privacy-first cycle companion. Designed with modern women in mind, it helps you track your health, understand your body, and flow with confidence—all while keeping your data strictly on your device.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.6,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ).animate().fadeIn(delay: 400.ms),

                      const SizedBox(height: 40),
                      _buildSectionTitle('Connect & Support'),
                      const SizedBox(height: 16),

                      // Action Tiles
                      _buildActionTile(
                        context,
                        Icons.bug_report_rounded,
                        'Report an Issue',
                        'Help us improve your experience',
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FeedbackScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActionTile(
                        context,
                        Icons.language_rounded,
                        'Official Website',
                        'github.com/hillhack/Her-Flowmate',
                        () => _launchUrl(
                          'https://github.com/hillhack/Her-Flowmate',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildActionTile(
                        context,
                        Icons.privacy_tip_rounded,
                        'Privacy Policy',
                        'Learn how we protect your data',
                        () => _launchUrl(
                          'mailto:herflowmate.app@gmail.com?subject=Privacy Inquiry',
                        ),
                      ),

                      const SizedBox(height: 48),
                      // Credits Footer
                      Column(
                        children: [
                          Text(
                            'Made with ❤️ in India',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '© 2026 Her-Flowmate Team',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textSecondary.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 800.ms),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    String sub,
    VoidCallback onTap,
  ) {
    return NeuContainer(
      radius: 24,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            NeuContainer(
              padding: const EdgeInsets.all(12),
              radius: 16,
              style: NeuStyle.convex,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    sub,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

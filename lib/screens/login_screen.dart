import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/glass_container.dart';
import '../widgets/delight_widgets.dart';
import '../widgets/neu_container.dart';
import 'onboarding_screen.dart';
import 'main_navigation_screen.dart';
import '../widgets/brand_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: GlassContainer(
              radius: 14,
              padding: const EdgeInsets.all(8),
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppTheme.textDark,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: AnimatedGlowBackground(
        child: Stack(
          children: [
            const FloatingSparkles(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            const Center(
                                  child: BrandLogo(
                                    size: 120,
                                    imagePath:
                                        'assets/images/feature_graphic.png',
                                    showName: true,
                                    nameFontSize: 36,
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 800.ms)
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  curve: Curves.easeOutBack,
                                ),

                            const SizedBox(height: 16),

                            Text(
                                  'Empowering Your Cycle Journey',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textSecondary.withValues(
                                      alpha: 0.8,
                                    ),
                                    letterSpacing: 1.2,
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.2),

                            const SizedBox(height: 64),

                            // Auth Buttons with better layout
                            _AuthButton(
                                  label: 'Continue with Google',
                                  icon: Icons.g_mobiledata_rounded,
                                  isPrimary: true,
                                  onTap: () => _handleLogin(context, true),
                                )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideY(begin: 0.2),

                            const SizedBox(height: 20),

                            _AuthButton(
                                  label: 'Continue as Guest',
                                  icon: Icons.person_outline_rounded,
                                  isPrimary: false,
                                  onTap: () => _handleLogin(context, false),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideY(begin: 0.2),

                            const SizedBox(height: 48),

                            // Privacy Section with better text
                            Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: AppTheme.glassDecoration(
                                    radius: 28,
                                    opacity: 0.08,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.shield_moon_rounded,
                                            size: 20,
                                            color: AppTheme.accentPink,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            'Privacy First',
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Your health data is encrypted and stays on your device. We never sell your personal information.',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary
                                              .withValues(alpha: 0.8),
                                          height: 1.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 600.ms)
                                .scale(begin: const Offset(0.9, 0.9)),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),

                    // Footer
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _FooterLink(label: 'Terms', onTap: () {}),
                          _Bullet(),
                          _FooterLink(label: 'Privacy', onTap: () {}),
                          _Bullet(),
                          _FooterLink(label: 'Support', onTap: () {}),
                        ],
                      ),
                    ).animate().fadeIn(delay: 800.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, bool isGoogle) async {
    final storage = context.read<StorageService>();
    await storage.completeLogin(isGoogle);

    if (!context.mounted) return;

    if (storage.hasCompletedOnboarding) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _AuthButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerButton(
      onTap: onTap,
      radius: 24,
      child: NeuContainer(
        radius: 24,
        gradient:
            isPrimary
                ? LinearGradient(
                  colors:
                      AppTheme.brandGradient.colors
                          .map((c) => c.withValues(alpha: 0.1))
                          .toList(),
                  begin: AppTheme.brandGradient.begin,
                  end: AppTheme.brandGradient.end,
                )
                : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? AppTheme.deepRose : AppTheme.accentPink,
                size: 26,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: AppTheme.accentPink.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}

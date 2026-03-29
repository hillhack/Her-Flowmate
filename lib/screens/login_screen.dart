import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';
import '../services/google_auth_services.dart';
import '../widgets/glass_container.dart';
import '../widgets/delight_widgets.dart';
import '../widgets/neu_container.dart';
import 'onboarding_screen.dart';
import 'main_navigation_screen.dart';
import '../widgets/brand_widgets.dart';
import '../widgets/google_auth_button.dart';

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
                      child: Center(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 24),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 48,
                            ),
                            decoration: AppTheme.premiumGlassDecoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const BrandLogo(
                                      size: 100,
                                      imagePath:
                                          'assets/images/feature_graphic.png',
                                      showName: true,
                                      nameFontSize: 32,
                                    )
                                    .animate()
                                    .fadeIn(duration: 800.ms)
                                    .scale(
                                      begin: const Offset(0.9, 0.9),
                                      curve: Curves.easeOutBack,
                                    ),

                                const SizedBox(height: 12),

                                Text(
                                      'Your Personal Health Sanctuary',
                                      style: AppTheme.outfit(
                                        fontSize: 14,
                                        color: AppTheme.textSecondary
                                            .withValues(alpha: 0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                    .animate()
                                    .fadeIn(delay: 400.ms)
                                    .slideY(begin: 0.2),

                                const SizedBox(height: 48),

                                // Auth Buttons
                                GoogleAuthButton(
                                      onTap: () => _handleLogin(context, true),
                                      onNameFetched: (name) {
                                        if (context.mounted) {
                                          final storage =
                                              context.read<StorageService>();
                                          _navigateToPostLogin(
                                            context,
                                            storage,
                                            name,
                                          );
                                        }
                                      },
                                    )
                                    .animate()
                                    .fadeIn(delay: 600.ms)
                                    .slideY(begin: 0.1),

                                const SizedBox(height: 16),

                                _AuthButton(
                                      label: 'Continue as Guest',
                                      icon: Icons.person_outline_rounded,
                                      isPrimary: false,
                                      onTap: () => _handleLogin(context, false),
                                    )
                                    .animate()
                                    .fadeIn(delay: 750.ms)
                                    .slideY(begin: 0.1),

                                const SizedBox(height: 40),

                                // Privacy Section
                                Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: AppTheme.glassDecoration(
                                        radius: 20,
                                        opacity: 0.05,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.shield_moon_rounded,
                                                size: 18,
                                                color: AppTheme.accentPink,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Privacy Assured',
                                                style: AppTheme.outfit(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Your data is private, encrypted, and stays with you.',
                                            style: AppTheme.outfit(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary
                                                  .withValues(alpha: 0.8),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                    .animate()
                                    .fadeIn(delay: 900.ms)
                                    .scale(begin: const Offset(0.95, 0.95)),
                              ],
                            ),
                          ),
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
    String? fetchedName;

    if (isGoogle) {
      final token = await GoogleAuthService.signInAndGetToken();

      if (token == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign-In failed or was canceled.'),
            ),
          );
        }
        return;
      }

      final userData = await GoogleAuthService.authenticateWithBackend(token);
      if (userData != null && userData['name'] != null) {
        fetchedName = userData['name'] as String;
      } else if (userData != null && userData['given_name'] != null) {
        // Fallback for different Google field naming
        fetchedName = userData['given_name'] as String;
      }
    }

    if (!context.mounted) return;

    await storage.completeLogin(isGoogle, fetchedName ?? '');

    if (!context.mounted) return;

    _navigateToPostLogin(context, storage, fetchedName);
  }

  void _navigateToPostLogin(
    BuildContext context,
    StorageService storage,
    String? fetchedName,
  ) {
    if (storage.hasCompletedOnboarding) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => OnboardingScreen(
                isEmailUser: true,
                prefillName: fetchedName ?? '',
              ),
        ),
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
                style: AppTheme.outfit(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ).copyWith(letterSpacing: 0.3),
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

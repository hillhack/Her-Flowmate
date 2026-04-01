import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';
import '../services/google_auth_services.dart';
import '../widgets/delight_widgets.dart';
import '../widgets/neu_container.dart';
import '../widgets/common/themed_container.dart';
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
            child: ThemedContainer(
              type: ContainerType.glass,
              radius: 14,
              padding: const EdgeInsets.all(8),
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: AppTheme.getBackgroundDecoration(context),
        child: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isSmall = constraints.maxWidth < 360;
                  final bool isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  final double horizontalPadding =
                      isSmall ? AppTheme.spacingMedium : AppTheme.spacingXlarge;
                  final double verticalPadding =
                      isSmall ? AppTheme.spacingLarge : AppTheme.spacingXXlarge;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: verticalPadding,
                      ),
                      child: Column(
                        children: [
                          Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 450,
                                minHeight: constraints.maxHeight * 0.7,
                              ),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmall ? 20 : 32,
                                  vertical: isSmall ? 32 : 48,
                                ),
                                decoration: AppTheme.loginContainerDecoration(
                                  isDark: isDark,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    BrandLogo(
                                          size: isSmall ? 80 : 100,
                                          imagePath:
                                              'assets/images/feature_graphic.png',
                                          showName: true,
                                          nameFontSize:
                                              AppTheme.adaptiveFontSize(
                                                context,
                                                32,
                                              ),
                                        )
                                        .animate()
                                        .fadeIn(duration: 800.ms)
                                        .scale(
                                          begin: const Offset(0.9, 0.9),
                                          curve: Curves.easeOutBack,
                                        ),
                                    const SizedBox(
                                      height: AppTheme.spacingSmall,
                                    ),
                                    Text(
                                      'Your Personal Health Sanctuary',
                                      style: AppTheme.outfit(
                                        context: context,
                                        fontSize: AppTheme.adaptiveFontSize(
                                          context,
                                          14,
                                        ),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ).animate().fadeIn(delay: 400.ms),
                                    SizedBox(
                                      height:
                                          isSmall
                                              ? AppTheme.spacingXlarge
                                              : AppTheme.spacingXXlarge,
                                    ),
                                    Semantics(
                                      label: 'Sign in with Google',
                                      button: true,
                                      child: GoogleAuthButton(
                                        onTap:
                                            () => _handleLogin(context, true),
                                      ),
                                    ).animate().fadeIn(delay: 400.ms),
                                    const SizedBox(
                                      height: AppTheme.spacingMedium,
                                    ),
                                    Semantics(
                                      label: 'Continue as guest',
                                      button: true,
                                      child: _AuthButton(
                                        label: 'Continue as Guest',
                                        icon: Icons.person_outline_rounded,
                                        isPrimary: false,
                                        onTap:
                                            () => _handleLogin(context, false),
                                        isSmall: isSmall,
                                      ),
                                    ).animate().fadeIn(delay: 500.ms),
                                    SizedBox(
                                      height:
                                          isSmall
                                              ? AppTheme.spacingXlarge
                                              : AppTheme.spacingHuge,
                                    ),
                                    ThemedContainer(
                                      type: ContainerType.glass,
                                      radius: 20,
                                      padding: EdgeInsets.all(
                                        isSmall ? 16 : 24,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.shield_moon_rounded,
                                                size: isSmall ? 16 : 18,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Privacy Assured',
                                                style: AppTheme.outfit(
                                                  context: context,
                                                  fontSize: isSmall ? 14 : 15,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Your data is private, encrypted, and stays with you.',
                                            style: AppTheme.outfit(
                                              context: context,
                                              fontSize: isSmall ? 11 : 12,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withOpacity(0.7),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _FooterLink(
                                  label: 'Terms',
                                  onTap:
                                      () => _showLegalDialog(
                                        context,
                                        'Terms of Service',
                                        'By using Her-Flowmate, you agree to our terms of service...',
                                      ),
                                ),
                                _Bullet(),
                                _FooterLink(
                                  label: 'Privacy',
                                  onTap:
                                      () => _showLegalDialog(
                                        context,
                                        'Privacy Policy',
                                        'Your privacy is our top priority. We do not sell your data...',
                                      ),
                                ),
                                _Bullet(),
                                _FooterLink(
                                  label: 'Support',
                                  onTap:
                                      () => _showLegalDialog(
                                        context,
                                        'Support',
                                        'Need help? Contact us at support@herflowmate.app',
                                      ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 800.ms),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, bool isGoogle) async {
    final storage = context.read<StorageService>();
    String? name;

    try {
      if (isGoogle) {
        if (kIsWeb) {
          await _handleWebSignIn(context);
          return;
        }

        final token = await GoogleAuthService.signInAndGetToken();
        if (token == null) {
          if (context.mounted) _showError(context, 'Sign-in canceled.');
          return;
        }

        final userData = await GoogleAuthService.authenticateWithBackend(token);
        name = userData?['name'] ?? userData?['given_name'];
      }

      if (!context.mounted) return;
      await storage.completeLogin(isGoogle, name ?? '');

      if (!context.mounted) return;
      _navigateToPostLogin(context, storage, name);
    } catch (e) {
      if (context.mounted) {
        _showError(context, 'An unexpected error occurred during sign-in.');
      }
    }
  }

  Future<void> _handleWebSignIn(BuildContext context) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Web Sign-In'),
            content: const Text(
              'Google Sign-In for web is not yet implemented in this preview. Please use Guest login.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign-in Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Retry'),
              ),
            ],
          ),
    );
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(child: Text(content)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
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
  final bool isSmall;

  const _AuthButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
    this.isSmall = false,
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
          padding: EdgeInsets.symmetric(
            vertical: isSmall ? 18 : 22,
            horizontal: isSmall ? 16 : 24,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? AppTheme.deepRose : AppTheme.accentPink,
                size: isSmall ? 22 : 26,
              ),
              SizedBox(width: isSmall ? 12 : 16),
              Flexible(
                child: Text(
                  label,
                  style: AppTheme.outfit(
                    fontSize: isSmall ? 15 : 17,
                    fontWeight: FontWeight.w700,
                  ).copyWith(letterSpacing: 0.3),
                  overflow: TextOverflow.ellipsis,
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
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }
}

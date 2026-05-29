import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';
import '../services/google_auth_services.dart';
import 'legal_screen.dart';
import 'onboarding_screen.dart';
import 'main_navigation_screen.dart';
import '../widgets/brand_widgets.dart';
import '../widgets/google_auth_button.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/common/neu_card.dart';
import '../widgets/common/app_back_button.dart';
import '../widgets/delight_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Center(
          child: Padding(
            padding: EdgeInsets.only(left: 12),
            child: AppBackButton(),
          ),
        ),
      ),
      body: AnimatedGlowBackground(
        showFlowers: true,
        child: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isSmall = constraints.maxWidth < 360;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              isSmall
                                  ? AppDesignTokens.space16
                                  : AppDesignTokens.space24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Hero(
                                  tag: 'brand_logo_login',
                                  child: BrandLogo(
                                    size: isSmall ? 80 : 100,
                                    imagePath:
                                        'assets/images/feature_graphic.png',
                                    showName: true,
                                    nameFontSize: AppTheme.adaptiveFontSize(
                                      context,
                                      32,
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(duration: 600.ms)
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  curve: Curves.easeOutBack,
                                ),
                            const SizedBox(height: AppDesignTokens.space8),
                            Text(
                                  'Your Personal Health Sanctuary',
                                  style: AppTheme.playfair(
                                    context: context,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.9),
                                  ),
                                  textAlign: TextAlign.center,
                                )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .moveY(begin: 10, end: 0),
                            const SizedBox(height: 8),
                            Text(
                              'Sign in to sync your health data securely.',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(delay: 400.ms),
                            SizedBox(
                              height:
                                  isSmall
                                      ? AppDesignTokens.space24
                                      : AppDesignTokens.space32,
                            ),
                            NeumorphicCard(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(
                                    isSmall
                                        ? AppDesignTokens.space20
                                        : AppDesignTokens.space32,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Semantics(
                                            label: 'Sign in with Google',
                                            button: true,
                                            child: GoogleAuthButton(
                                              onTap:
                                                  _isLoading
                                                      ? null
                                                      : () => _handleLogin(
                                                        context,
                                                        true,
                                                      ),
                                            ),
                                          )
                                          .animate()
                                          .fadeIn(delay: 600.ms)
                                          .moveY(begin: 20, end: 0),
                                      const SizedBox(
                                        height: AppDesignTokens.space16,
                                      ),
                                      Semantics(
                                            label: 'Continue as guest',
                                            button: true,
                                            child: PrimaryButton(
                                              label: 'Continue as Guest',
                                              icon:
                                                  Icons.person_outline_rounded,
                                              isSecondary: true,
                                              isLoading: false,
                                              onTap:
                                                  _isLoading
                                                      ? null
                                                      : () => _handleLogin(
                                                        context,
                                                        false,
                                                      ),
                                            ),
                                          )
                                          .animate()
                                          .fadeIn(delay: 800.ms)
                                          .moveY(begin: 20, end: 0),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 500.ms)
                                .scale(begin: const Offset(0.95, 0.95)),
                            SizedBox(
                              height:
                                  isSmall
                                      ? AppDesignTokens.space32
                                      : AppDesignTokens.space48,
                            ),
                            NeumorphicCard(
                                  padding: EdgeInsets.all(
                                    isSmall
                                        ? AppDesignTokens.space16
                                        : AppDesignTokens.space24,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.verified_user_rounded,
                                              size: isSmall ? 16 : 18,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Privacy Assured',
                                            style: AppTheme.outfit(
                                              context: context,
                                              fontSize: isSmall ? 14 : 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Your health data is encrypted, private, \nand never shared without your consent.',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 1000.ms)
                                .moveY(begin: 20, end: 0),
                            const SizedBox(height: 32),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
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
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              Container(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.4),
                child: Center(
                  child: NeumorphicCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.roseCoralPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Authenticating...',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().scale(curve: Curves.easeOutBack),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, bool isGoogle) async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
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
          if (context.mounted) {
            _showError(
              context,
              'Sign-in canceled.',
              () => _handleLogin(context, true),
            );
          }
          return;
        }

        final userData = await GoogleAuthService.authenticateWithBackend(token);
        // Dead code
        name =
            userData?['display_name'] ??
            userData?['name'] ??
            userData?['given_name'];
      }
      if (!context.mounted) return;
      await storage.completeLogin(isGoogle, name ?? '');

      if (!context.mounted) return;
      _showSuccessSnack(context);
      _navigateToPostLogin(context, storage, name);
    } catch (e) {
      if (context.mounted) {
        String msg =
            'Unable to connect to Her-Flowmate. Please check your internet connection.';
        if (e is TimeoutException) {
          msg =
              'The server is taking a while to wake up. ☁️\n\nThis sometimes happens on the first try. Please tap retry to wake it up!';
        }
        _showError(context, msg, () => _handleLogin(context, isGoogle));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleWebSignIn(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return NeumorphicCard(
          margin: const EdgeInsets.all(AppDesignTokens.space16),
          padding: const EdgeInsets.all(AppDesignTokens.space24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppDesignTokens.radiusXS,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDesignTokens.space24),
                Text(
                  'Web Sign-In',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDesignTokens.space16),
                Text(
                  'Google Sign-In is coming soon to the web version.\n\nFor now, please use the "Continue as Guest" option to explore the app.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDesignTokens.space24),
                PrimaryButton(
                  label: 'Got it',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showError(BuildContext context, String message, VoidCallback onRetry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return NeumorphicCard(
              margin: const EdgeInsets.all(AppDesignTokens.space16),
              padding: const EdgeInsets.all(AppDesignTokens.space24),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            AppDesignTokens.radiusXS,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDesignTokens.space32),
                    Container(
                      padding: const EdgeInsets.all(AppDesignTokens.space16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: Theme.of(context).colorScheme.error,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: AppDesignTokens.space24),
                    Text(
                      'Authentication Error',
                      style: AppTheme.playfair(
                        context: context,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDesignTokens.space16),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDesignTokens.space32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                            ),
                            child: Text(
                              'Dismiss',
                              style: AppTheme.outfit(
                                context: context,
                                fontSize: AppDesignTokens.bodyLargeSize,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDesignTokens.space16),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Try Again',
                            onTap: () {
                              Navigator.pop(context);
                              onRetry();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
            .animate()
            .slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic)
            .fadeIn();
      },
    );
  }

  void _showSuccessSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: ListTile(
          leading: Icon(Icons.check_circle, color: Colors.lightGreenAccent),
          title: Text(
            "Login Successfull!",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LegalScreen(title: title, content: content),
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

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label link',
      button: true,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDesignTokens.space8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            label,
            style: AppTheme.outfit(
              context: context,
              fontSize: AppDesignTokens.captionSize,
              fontWeight: FontWeight.w600,
            ).copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
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
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
    );
  }
}

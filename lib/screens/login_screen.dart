import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';
import '../services/google_auth_services.dart';
import '../widgets/themed_container.dart';
import 'legal_screen.dart';
import 'onboarding_screen.dart';
import 'main_navigation_screen.dart';
import '../widgets/brand_widgets.dart';
import '../widgets/google_auth_button.dart';
import '../widgets/common/primary_button.dart';
import '../widgets/common/neu_card.dart';
import '../widgets/common/app_back_button.dart';

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
      body: Container(
        decoration: AppTheme.getBackgroundDecoration(context),
        child: Stack(
          children: [
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isSmall = constraints.maxWidth < 360;

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmall ? 16 : 24,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Hero(
                                tag: 'brand_logo_login',
                                child: BrandLogo(
                                  size: isSmall ? 80 : 100,
                                  imagePath: 'assets/images/feature_graphic.png',
                                  showName: true,
                                  nameFontSize: AppTheme.adaptiveFontSize(
                                    context,
                                    32,
                                  ),
                                ),
                              ).animate().fadeIn(duration: 500.ms).scale(),
                              const SizedBox(height: AppTheme.spacingSm),
                              Text(
                                'Your Personal Health Sanctuary',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to sync your health data securely.',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height:
                                    isSmall
                                        ? AppTheme.spacingLg
                                        : AppTheme.spacingXl,
                              ),
                              ThemedContainer(
                                type: ContainerType.neu,
                                radius: 32,
                                padding: EdgeInsets.all(isSmall ? 20 : 32),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Semantics(
                                      label: 'Sign in with Google',
                                      button: true,
                                      child: GoogleAuthButton(
                                        onTap:
                                            _isLoading
                                                ? null
                                                : () =>
                                                    _handleLogin(context, true),
                                      ),
                                    ).animate().fadeIn(delay: 400.ms),
                                    const SizedBox(
                                      height: AppTheme.spacingMedium,
                                    ),
                                    Semantics(
                                      label: 'Continue as guest',
                                      button: true,
                                      child: PrimaryButton(
                                        label: 'Continue as Guest',
                                        icon: Icons.person_outline_rounded,
                                        isSecondary: true,
                                        isLoading: false,
                                        onTap: _isLoading
                                            ? null
                                            : () => _handleLogin(context, false),
                                      ),
                                    ).animate().fadeIn(delay: 500.ms),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height:
                                    isSmall
                                        ? AppTheme.spacingXlarge
                                        : AppTheme.spacingHuge,
                              ),
                              ThemedContainer(
                                type: ContainerType.neu,
                                radius: 20,
                                padding: EdgeInsets.all(isSmall ? 16 : 24),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.lock_rounded,
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
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
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
                    ],
                  );
                },
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: NeumorphicCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Authenticating...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
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
        name = userData?['display_name'] ?? userData?['name'] ?? userData?['given_name'];
      }

      if (!context.mounted) return;
      await storage.completeLogin(isGoogle, name ?? '');

      if (!context.mounted) return;
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.textDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Web Sign-In',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Google Sign-In is coming soon to the web version. \n\nFor now, please use the "Continue as Guest" option to explore the app.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
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
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
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
                      color: AppTheme.textDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Sign-in Error',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onRetry();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            label,
            style: AppTheme.outfit(
              context: context,
              fontSize: 12,
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

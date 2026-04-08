import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import '../widgets/delight_widgets.dart';
import '../widgets/themed_container.dart';
import '../widgets/brand_widgets.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<NeonButterflyState> _b1Key = GlobalKey<NeonButterflyState>();
  final GlobalKey<NeonButterflyState> _b2Key = GlobalKey<NeonButterflyState>();
  final GlobalKey<NeonButterflyState> _b3Key = GlobalKey<NeonButterflyState>();
  bool _isNavigating = false;

  void _onBeginJourney() async {
    if (_isNavigating) return;
    setState(() => _isNavigating = true);

    _b1Key.currentState?.triggerTapAnimation();
    _b2Key.currentState?.triggerTapAnimation();
    _b3Key.currentState?.triggerTapAnimation();
    showPhaseDelight(context, 'Follicular');

    // Immediate navigation, no artificial 1s delay
    if (mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  Future<void> _resetExperience() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset All Data?'),
            content: const Text(
              'This will erase all your period logs and preferences. This cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reset'),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      await context.read<StorageService>().stopAndReset();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('App data has been reset')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      body: AnimatedGlowBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isSmall = constraints.maxWidth < 360;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmall ? 16 : 32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        Hero(
                          tag: 'brand_logo',
                          child: BrandLogo(
                            size: isSmall ? 110 : 150,
                            imagePath: 'assets/images/feature_graphic.png',
                            showName: true,
                            nameFontSize: 42,
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 800.ms)
                            .scale(
                              begin: const Offset(0.9, 0.9),
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: 16),
                        Text(
                          'Your intelligent cycle companion',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
                        const SizedBox(height: 64),
                        Semantics(
                              label: 'Begin journey',
                              button: true,
                              child: ShimmerButton(
                                onTap: _onBeginJourney,
                                child: ThemedContainer(
                                  type: ContainerType.neu,
                                  radius: 24,
                                  child: Container(
                                    width: double.infinity,
                                    height: isSmall ? 56 : 72,
                                    alignment: Alignment.center,
                                    child:
                                        _isNavigating
                                            ? const CircularProgressIndicator()
                                            : Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                NeonButterfly(
                                                  key: _b2Key,
                                                  size: isSmall ? 18 : 22,
                                                  animateOnTap: true,
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Begin Journey',
                                                  style: theme
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(
                                                        color:
                                                            colorScheme.primary,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        letterSpacing: 1.2,
                                                      ),
                                                ),
                                                const SizedBox(width: 12),
                                                NeonButterfly(
                                                  key: _b3Key,
                                                  size: isSmall ? 22 : 28,
                                                  color: colorScheme.secondary
                                                      .withValues(alpha: 0.8),
                                                  animateOnTap: true,
                                                ),
                                              ],
                                            ),
                                  ),
                                ),
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 600.ms)
                            .slideY(begin: 0.3, curve: Curves.easeOut),
                        const SizedBox(height: 32),
                        TextButton(
                          onPressed: _resetExperience,
                          child: Text(
                            'Reset Experience',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 48,
                        ), // Extra bottom padding for system safe area
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

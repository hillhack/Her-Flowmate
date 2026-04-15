import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';
import '../widgets/delight_widgets.dart';
import '../widgets/brand_widgets.dart';
import '../widgets/pansy_animation.dart';
import '../utils/app_theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isNavigating = false;
  bool _showPansy = false;

  // Controller for the tactile button press effect
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressScale = Tween<double>(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  Future<void> _onBeginJourney() async {
    if (_isNavigating) return;

    // ── Step 1: Tactile button press ─────────────────────────────────────
    await _pressCtrl.forward();
    await _pressCtrl.reverse();

    setState(() {
      _isNavigating = true;
      _showPansy = true;
    });

    // ── Step 2: Pansies fill screen — 2500 ms ─────────────────────────
    await Future.delayed(2500.ms);

    if (!mounted) return;

    // ── Step 3: Navigate ─────────────────────────────────────────────────
    await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionDuration: 1000.ms,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Fade to login screen
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    if (mounted) {
      setState(() {
        _isNavigating = false;
        _showPansy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // ── Main screen content ────────────────────────────────────────
          AnimatedGlowBackground(
            showSparkles: true,
            showFlowers: true,
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isSmall = constraints.maxWidth < 360;
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 20 : 32,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),

                            // ── Logo with floating animation ─────────────
                            Hero(
                                  tag: 'brand_logo',
                                  child: BrandLogo(
                                    size: isSmall ? 120 : 160,
                                    imagePath:
                                        'assets/images/feature_graphic.png',
                                    showName: true,
                                    nameFontSize: isSmall ? 36 : 48,
                                  ),
                                )
                                .animate(onPlay: (c) => c.repeat(reverse: true))
                                .moveY(
                                  begin: -5,
                                  end: 5,
                                  duration: 3.seconds,
                                  curve: Curves.easeInOutSine,
                                )
                                .animate()
                                .slideY(
                                  begin: 0.2,
                                  duration: 800.ms,
                                  curve: Curves.easeOutBack,
                                )
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  curve: Curves.easeOutBack,
                                ),

                            const SizedBox(height: 16),

                            // ── Tagline ──────────────────────────────────
                            ShaderMask(
                              shaderCallback:
                                  (bounds) => AppTheme.brandGradient
                                      .createShader(bounds),
                              child: Text(
                                'Your intelligent cycle companion',
                                style: AppTheme.poppins(
                                  fontSize: isSmall ? 16 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ).animate().slideY(
                              begin: 0.2,
                              end: 0,
                              delay: 400.ms,
                              duration: 800.ms,
                            ),

                            const SizedBox(height: 80),

                            // ── BEGIN JOURNEY button (tactile press) ─────
                            AnimatedBuilder(
                              animation: _pressScale,
                              builder:
                                  (_, child) => Transform.scale(
                                    scale: _pressScale.value,
                                    child: child,
                                  ),
                              child: Semantics(
                                label: 'Begin journey',
                                button: true,
                                child: ShimmerButton(
                                  onTap: _onBeginJourney,
                                  radius: AppDesignTokens.radiusXL,
                                  child: Container(
                                    width: double.infinity,
                                    height: AppDesignTokens.buttonHeight + 8,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                        AppDesignTokens.radiusXL,
                                      ),
                                      gradient: AppTheme.brandGradient,
                                      boxShadow: AppTheme.neuShadows(
                                        isDark: isDark,
                                        size: ShadowSize.card,
                                      ),
                                    ),
                                    child:
                                        _isNavigating && !_showPansy
                                            ? const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                              ),
                                            )
                                            : Center(
                                              child: Text(
                                                'BEGIN JOURNEY',
                                                style: AppTheme.poppins(
                                                  fontSize: isSmall ? 18 : 20,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 2.0,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                  ),
                                ),
                              ),
                            ).animate().slideY(
                              begin: 0.4,
                              end: 0,
                              delay: 800.ms,
                              curve: Curves.easeOutCubic,
                            ),

                            const SizedBox(height: 88),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Pansy animation overlay ────────────────────────────────
          if (_showPansy) const Positioned.fill(child: PansyAnimationOverlay()),
        ],
      ),
    );
  }
}

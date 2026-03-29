import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';
import '../widgets/delight_widgets.dart';
import '../widgets/neu_container.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedGlowBackground(
        child: SafeArea(
          child: Stack(
            children: [
              const FloatingSparkles(),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      // Integrated Brand Identity (Icon + Name)
                      Center(
                        child: const BrandLogo(
                              size: 150,
                              imagePath: 'assets/images/feature_graphic.png',
                              showName: true,
                              nameFontSize: 42,
                            )
                            .animate(
                              onPlay:
                                  (controller) =>
                                      controller.repeat(reverse: true),
                            )
                            .shimmer(
                              duration: 3.seconds,
                              color: Colors.white30,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your intelligent cycle companion',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 500.ms, duration: 1.seconds),
                      const SizedBox(height: 64),
                      // Bottom area: Main Button with Shimmer & Butterflies
                      Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // Floating butterfly #1 (Interactive)
                              Positioned(
                                top: -45,
                                right: 25,
                                child: NeonButterfly(
                                  key: _b1Key,
                                  size: 26,
                                  animateOnTap: true,
                                ),
                              ),
                              ShimmerButton(
                                onTap: () {
                                  // Trigger all butterflies
                                  _b1Key.currentState?.triggerTapAnimation();
                                  _b2Key.currentState?.triggerTapAnimation();
                                  _b3Key.currentState?.triggerTapAnimation();

                                  showPhaseDelight(context, 'Follicular');
                                  Future.delayed(1000.ms, () {
                                    if (context.mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const LoginScreen(),
                                        ),
                                      );
                                    }
                                  });
                                },
                                child: NeuContainer(
                                  radius: 24,
                                  child: Container(
                                    width: double.infinity,
                                    height: 72,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        NeonButterfly(
                                          key: _b2Key,
                                          size: 22,
                                          animateOnTap: true,
                                        ),
                                        const SizedBox(width: 14),
                                        Text(
                                          'Begin Journey',
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w800,
                                            color: AppTheme.accentPink,
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        NeonButterfly(
                                          key: _b3Key,
                                          size: 28,
                                          color: const Color(
                                            0xFFE6A8FF,
                                          ), // Lavender
                                          animateOnTap: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 1.seconds, duration: 800.ms)
                          .slideY(begin: 0.5, curve: Curves.easeOutCubic),
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: () async {
                          await context.read<StorageService>().stopAndReset();
                        },
                        child: Text(
                          'Reset Experience',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.4,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
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
}

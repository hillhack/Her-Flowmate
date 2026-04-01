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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final bool isSmall = constraints.maxWidth < 360;
              final double horizontalPadding =
                  isSmall ? AppTheme.spacingMedium : AppTheme.spacingXlarge;

              return Stack(
                children: [
                  const FloatingSparkles(),
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: isSmall ? AppTheme.spacingHuge : 80),
                          Center(
                            child: BrandLogo(
                                  size: isSmall ? 110 : 150,
                                  imagePath:
                                      'assets/images/feature_graphic.png',
                                  showName: true,
                                  nameFontSize: AppTheme.adaptiveFontSize(
                                    context,
                                    42,
                                  ),
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
                          const SizedBox(height: AppTheme.spacingMedium),
                          Text(
                            'Your intelligent cycle companion',
                            style: GoogleFonts.inter(
                              fontSize: isSmall ? 15 : 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.5,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(
                            delay: 500.ms,
                            duration: 1.seconds,
                          ),
                          SizedBox(
                            height:
                                isSmall
                                    ? AppTheme.spacingXXlarge
                                    : AppTheme.spacingHuge,
                          ),

                          // Action Area
                          ShimmerButton(
                                onTap: () {
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
                                        Flexible(
                                          child: NeonButterfly(
                                            key: _b2Key,
                                            size: isSmall ? 18 : 22,
                                            animateOnTap: true,
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              isSmall
                                                  ? AppTheme.spacingSmall
                                                  : AppTheme.spacingMedium,
                                        ),
                                        Flexible(
                                          flex: 3,
                                          child: Text(
                                            'Begin Journey',
                                            style: GoogleFonts.poppins(
                                              fontSize: isSmall ? 17 : 20,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.accentPink,
                                              letterSpacing: 1.2,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        SizedBox(
                                          width:
                                              isSmall
                                                  ? AppTheme.spacingSmall
                                                  : AppTheme.spacingMedium,
                                        ),
                                        Flexible(
                                          child: NeonButterfly(
                                            key: _b3Key,
                                            size: isSmall ? 22 : 28,
                                            color: const Color(0xFFE6A8FF),
                                            animateOnTap: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                              .animate()
                              .fadeIn(delay: 1.seconds, duration: 800.ms)
                              .slideY(begin: 0.5, curve: Curves.easeOutCubic),

                          const SizedBox(height: AppTheme.spacingXlarge),
                          TextButton(
                            onPressed: () async {
                              await context
                                  .read<StorageService>()
                                  .stopAndReset();
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
                          const SizedBox(height: AppTheme.spacingXlarge),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

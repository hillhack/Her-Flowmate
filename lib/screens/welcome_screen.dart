import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import 'login_screen.dart';
import '../widgets/delight_widgets.dart';
import '../widgets/glass_container.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Stack(
            children: [
              const FloatingSparkles(),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    
                    // Top area: Glowing Logo
                    Center(
                      child: GlassContainer(
                        radius: 50,
                        opacity: 0.15,
                        borderColor: AppTheme.accentPink.withOpacity(0.5),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: AppTheme.accentPink,
                            size: 64,
                          ),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .shimmer(duration: 2.seconds, color: Colors.white24)
                       .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 2.seconds, curve: Curves.easeInOut),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Center area: App Name & Subtext
                    Text(
                      'HerFlowmate',
                      style: GoogleFonts.poppins(
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                        letterSpacing: -1,
                      ),
                    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.2, curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 12),
                    
                    Text(
                      'Your gentle cycle companion',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
                    
                    const Spacer(flex: 4),
                    
                    // Bottom area: Main Button
                    GlassContainer(
                      radius: 24,
                      onTap: () {
                        showPhaseDelight(context, 'Follicular');
                        Future.delayed(700.ms, () {
                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        height: 72,
                        alignment: Alignment.center,
                        child: Text(
                          'Get Started',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.accentPink,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () async {
                        await context.read<StorageService>().stopAndReset();
                      },
                      child: Text(
                        'Reset App Data',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary.withOpacity(0.5),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

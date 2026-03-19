import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../services/storage_service.dart';
import '../widgets/glass_container.dart';
import 'onboarding_screen.dart';
import 'main_navigation_screen.dart';

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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: GlassContainer(
              radius: 12,
              padding: EdgeInsets.zero,
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                
                Text(
                  'Continue to\nHerFlowmate',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textDark,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn().slideY(begin: -0.2),
                
                const SizedBox(height: 64),
                
                // Google Login Button
                _AuthButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata_rounded,
                  onTap: () => _handleLogin(context, true),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                
                const SizedBox(height: 24),
                
                // Guest Login Button
                _AuthButton(
                  label: 'Continue as Guest',
                  icon: Icons.person_outline_rounded,
                  onTap: () => _handleLogin(context, false),
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                
                const Spacer(flex: 2),
                
                // Data Info Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      'Guest Mode Privacy',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your data is stored only on this device.\nIf the app is removed, your data will not be recovered.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary.withOpacity(0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context, bool isGoogle) async {
    final storage = context.read<StorageService>();
    
    // 1. Update state. 
    await storage.completeLogin(isGoogle);

    // 2. Navigate explicitly to the next screen.
    // This is more robust than relying on the root MaterialApp home changing.
    if (context.mounted) {
      final nextScreen = storage.hasCompletedOnboarding 
          ? const MainNavigationScreen() 
          : const OnboardingScreen();
          
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => nextScreen),
        (route) => false,
      );
    }
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _AuthButton({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      radius: 24,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.accentPink, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

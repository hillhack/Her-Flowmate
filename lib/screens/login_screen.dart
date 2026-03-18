import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Background Element
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.pink.shade300.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat()).rotate(duration: 10.seconds),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.purple.shade300.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scaleXY(end: 1.2, duration: 4.seconds),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Icon(Icons.water_drop_rounded, size: 80, color: theme.colorScheme.primary)
                      .animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  Text(
                    'Her-Flowmate',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                  const SizedBox(height: 16),
                  Text(
                    'Your living cycle companion.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  const Spacer(flex: 2),
                  
                  // Login Buttons
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        // Mock login
                        await context.read<StorageService>().completeLogin(true, 'Emma');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink.shade500,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Login to Sync',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                  const SizedBox(height: 16),
                  
                  TextButton(
                    onPressed: () async {
                      // Guest flow
                      await context.read<StorageService>().completeLogin(false);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      foregroundColor: Colors.grey.shade700,
                    ),
                    child: Text(
                      'Continue as Guest',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                  
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

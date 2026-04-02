import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/storage_service.dart';

class GreetingSection extends StatelessWidget {
  final StorageService storage;

  const GreetingSection({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    String emoji = '☀️';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
      emoji = '🌤️';
    } else if (hour >= 17 || hour < 5) {
      greeting = 'Good Evening';
      emoji = '🌙';
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$emoji $greeting, ',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${storage.userName.split(' ').first}!',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            height: 1.0,
            letterSpacing: -0.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.05);
  }
}

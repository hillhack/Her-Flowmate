import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';

class GreetingSection extends StatelessWidget {
  final StorageService storage;

  const GreetingSection({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting = 'Good Morning';
    String emoji = '🌸';
    if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
      emoji = '✨';
    } else if (hour >= 17 || hour < 5) {
      greeting = 'Good Evening';
      emoji = '🌙';
    }

    final name = storage.userName.split(' ').first;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$emoji $greeting',
              style: AppTheme.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.secondaryText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AppTheme.isSmallScreen(context)
        ? Text(
          '$name!',
          style: AppTheme.playfair(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: context.onSurface,
          ),
        )
        : Text(
          '$name, welcome back',
          style: AppTheme.playfair(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: context.onSurface,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.05);
  }
}

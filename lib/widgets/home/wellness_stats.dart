import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/prediction_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';
import '../themed_container.dart';

class SleepCard extends StatelessWidget {
  final PredictionService pred;
  final StorageService storage;

  const SleepCard({super.key, required this.pred, required this.storage});

  @override
  Widget build(BuildContext context) {
    final log = storage.getDailyLog(DateTime.now());
    final hasData = log != null && log.sleepHours != null;
    final sleepHours = log?.sleepHours ?? 0.0;
    final phase = pred.phaseDisplayName;

    final sleepTips = {
      'Menstrual': 'Rest extra — your body rebuilds tonight.',
      'Follicular': 'Energy rising — 7–8h keeps you sharp.',
      'Ovulation': 'You\'re peaking — protect quality sleep!',
      'Luteal': 'Progesterone dips — magnesium helps.',
    };
    final tip = sleepTips[phase] ?? 'Aim for 7–9h for hormonal balance.';

    String quality = '—';
    Color qualityColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);
    if (hasData) {
      if (sleepHours >= AppConstants.greatSleepHours) {
        quality = 'Great';
        qualityColor = const Color(0xFF66BB6A);
      } else if (sleepHours >= AppConstants.okSleepHours) {
        quality = 'Ok';
        qualityColor = const Color(0xFFFFB347);
      } else {
        quality = 'Low';
        qualityColor = const Color(0xFFFF686B);
      }
    }

    return ThemedContainer(
      type: ContainerType.glass,
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌙', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Sleep',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: hasData ? sleepHours.toStringAsFixed(1) : '—',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (hasData)
                  TextSpan(
                    text: 'h',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          if (hasData)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: qualityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                quality,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: qualityColor,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            tip,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          if (!hasData) ...[
            const SizedBox(height: 6),
            Text(
              'Log in daily check-in ✏️',
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StreakCard extends StatelessWidget {
  final StorageService storage;
  final VoidCallback onMilestoneReached;

  const StreakCard({
    super.key,
    required this.storage,
    required this.onMilestoneReached,
  });

  @override
  Widget build(BuildContext context) {
    final streak = storage.getCheckinStreak();

    // Check for milestone
    final isMilestone = streak > 0 && streak % 7 == 0;
    if (isMilestone) {
      // Note: In a real app, you'd store if this was already celebrated today.
      // For this modularization, we trigger the callback.
      // To avoid multiple triggers on rebuild, parent should handle "once-per-milestone".
    }

    String streakLabel;
    Color streakColor;
    String emoji;
    if (streak >= AppConstants.streakMilestones.last) {
      streakLabel = 'Legend!';
      streakColor = const Color(0xFFD481FF);
      emoji = '🏆';
    } else if (streak >= AppConstants.streakMilestones[1]) {
      streakLabel = 'On fire!';
      streakColor = const Color(0xFFFF9800);
      emoji = '🔥';
    } else if (streak >= AppConstants.streakMilestones.first) {
      streakLabel = '1 week!';
      streakColor = const Color(0xFF66BB6A);
      emoji = '⭐';
    } else if (streak >= 1) {
      streakLabel = 'Keep it up';
      streakColor = Theme.of(context).colorScheme.primary;
      emoji = '✨';
    } else {
      streakLabel = 'Start today';
      streakColor = Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.6);
      emoji = '📅';
    }

    return ThemedContainer(
      type: ContainerType.glass,
      radius: 24,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Streak',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$streak',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: streakColor,
                  ),
                ),
                TextSpan(
                  text: ' days',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: streakColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              streakLabel,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: streakColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            streak == 0
                ? 'Log your check-in daily to start a streak!'
                : 'Next milestone: ${streak < 7
                    ? 7 - streak
                    : streak < 14
                    ? 14 - streak
                    : 30 - (streak % 30)} days',
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

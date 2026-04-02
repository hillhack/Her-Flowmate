import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/prediction_service.dart';
import '../../services/storage_service.dart';
import '../themed_container.dart';
import 'cycle_core_ring.dart';
import 'predictive_chips.dart';
import 'wellness_goals_card.dart';

class TTCDashboard extends StatelessWidget {
  final StorageService storage;
  final PredictionService pred;

  const TTCDashboard({super.key, required this.storage, required this.pred});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RepaintBoundary(
          child: CycleCoreRing(pred: pred)
              .animate()
              .fadeIn(duration: 600.ms)
              .scale(begin: const Offset(0.9, 0.9)),
        ),
        const SizedBox(height: 24),
        RepaintBoundary(
          child: PredictiveChips(
            pred: pred,
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
        ),
        const SizedBox(height: 24),
        _buildConceptionTipsCard(context, pred),
        const SizedBox(height: 24),
        WellnessGoalsCard(storage: storage),
      ],
    );
  }

  Widget _buildConceptionTipsCard(
    BuildContext context,
    PredictionService pred,
  ) {
    final chance = pred.currentConceptionChance;
    final day = pred.currentCycleDay;

    String title = 'Keep tracking!';
    String tip =
        'Logging your daily symptoms helps us predict your fertile window more accurately.';
    IconData icon = Icons.auto_awesome_rounded;

    if (chance >= 25) {
      title = 'Peak Fertility! ✨';
      tip =
          'You are in your most fertile window. This is the best time for intimacy if you are trying to conceive.';
      icon = Icons.favorite_rounded;
    } else if (chance >= 10) {
      title = 'Fertile Window Approaching';
      tip =
          'Your chances of conception are rising. Stay hydrated and track your cervical mucus.';
      icon = Icons.water_drop_rounded;
    } else if (day > 0 && day <= 5) {
      title = 'Cycle Just Started';
      tip =
          'Focus on rest and iron-rich foods. Your fertile window will begin in about a week.';
      icon = Icons.wb_sunny_rounded;
    }

    return Semantics(
      button: true,
      label: 'Conception tips: $title',
      child: ThemedContainer(
        type: ContainerType.glass,
        padding: const EdgeInsets.all(24),
        radius: 28,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tip,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }
}

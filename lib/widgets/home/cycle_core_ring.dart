import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/prediction_service.dart';
import '../../utils/app_theme.dart';
import '../info_widgets.dart';
import '../themed_container.dart';

import 'segmented_cycle_ring.dart';

class CycleCoreRing extends StatelessWidget {
  final PredictionService pred;

  const CycleCoreRing({super.key, required this.pred});

  @override
  Widget build(BuildContext context) {
    final phaseName = pred.phaseDisplayName;
    final day = pred.currentCycleDay == 0 ? 1 : pred.currentCycleDay;
    final cycleLen = pred.averageCycleLength;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final ringSize = (screenWidth * 0.75).clamp(240.0, 320.0);
    final innerSize = ringSize * 0.72;

    return Semantics(
      label: 'Cycle summary ring showing $phaseName phase at day $day of $cycleLen',
      child: SizedBox(
        width: ringSize + 60, // Added space for labels
        height: ringSize + 60,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ── 1. The Premium Segmented Ring ───────────────────────────────
            SegmentedCycleRing(
              currentDay: day,
              cycleLength: cycleLen,
              logs: pred.storageService.getLogs(),
              size: ringSize,
            ),

            // ── 2. The Center Info Area (Glass Morphic) ───────────────────
            ThemedContainer(
              type: ContainerType.glass,
              radius: innerSize / 2,
              padding: const EdgeInsets.all(12),
              onTap: () {
                final biology = pred.getPhaseBiology(day);
                final phase = pred.phaseDisplayName;
                final symptoms = AppTheme.getPhaseSymptoms(phase);

                showGlassInfoPopup(
                  context,
                  title: '$phase Phase',
                  explanation:
                      '${biology['hormoneActivity']}\n\n${biology['energy']}\n\n${biology['mood']}',
                  tip: 'Common symptoms: ${symptoms.join(", ")}',
                );
              },
              child: Container(
                width: innerSize,
                height: innerSize,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Day count (Top label)
                    Text(
                      'Day $day / $cycleLen',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Phase Name (Bold Title)
                    Text(
                      phaseName,
                      style: AppTheme.playfair(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.getPhaseColor(pred.currentPhase),
                      ),
                    ),
                    
                    Text(
                      'Phase',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sub-stat Badge (e.g., Ovulation in X days)
                    _StatusBadge(pred: pred),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PredictionService pred;
  const _StatusBadge({required this.pred});

  @override
  Widget build(BuildContext context) {
    String label = '';
    IconData icon = Icons.auto_awesome_rounded;

    if (pred.currentPhase == CyclePhase.menstrual) {
      label = 'Period ${pred.currentCycleDay} of 5';
      icon = Icons.water_drop_rounded;
    } else if (pred.daysUntilOvulation == 0) {
      label = 'Ovulation today';
      icon = Icons.favorite_rounded;
    } else if (pred.daysUntilOvulation > 0) {
      label = 'Ovulation in ${pred.daysUntilOvulation} days';
      icon = Icons.favorite_rounded;
    } else {
      label = '${pred.daysUntilNextPeriod} days to next cycle';
      icon = Icons.calendar_month_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

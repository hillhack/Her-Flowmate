import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/prediction_service.dart';
import '../../utils/app_theme.dart';
import '../info_widgets.dart';
import 'package:intl/intl.dart';
import 'evolution_wheel.dart';
import '../themed_container.dart';

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
    final ringSize = (screenWidth * 0.55).clamp(180.0, 260.0);
    final innerSize = ringSize * 0.8;

    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Evolution Wheel (Custom Painted Progress)
          EvolutionWheel(
            size: ringSize,
            progress: day / (cycleLen == 0 ? 28 : cycleLen),
            activeColor: AppTheme.phaseColor(phaseName),
          ),

          // Inner Content Card
          RepaintBoundary(
            child: ThemedContainer(
              type: ContainerType.glass,
              radius: ringSize / 2,
              padding: EdgeInsets.zero,
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
              child: SizedBox(
                width: innerSize,
                height: innerSize,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        phaseName.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: (ringSize * 0.085).clamp(14.0, 18.0),
                          fontWeight: FontWeight.w900,
                          color: AppTheme.getPhaseColor(pred.currentPhase),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ChanceBadge(chance: pred.currentConceptionChance),
                      const SizedBox(height: 16),
                      _buildMiniInfo(
                        context,
                        label: 'NEXT PERIOD',
                        value:
                            pred.nextPeriodDate != null
                                ? DateFormat(
                                  'MMM d',
                                ).format(pred.nextPeriodDate!)
                                : '--',
                      ),
                      const SizedBox(height: 8),
                      _buildMiniInfo(
                        context,
                        label: 'OVULATION',
                        value:
                            pred.daysUntilOvulation == 0
                                ? 'Today'
                                : (pred.daysUntilOvulation > 0
                                    ? 'in ${pred.daysUntilOvulation}d'
                                    : '--'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
            letterSpacing: 0.8,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ChanceBadge extends StatelessWidget {
  final int chance;
  const _ChanceBadge({required this.chance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_rounded,
            size: 10,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '$chance% Chance',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

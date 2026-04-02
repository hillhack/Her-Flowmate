import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/prediction_service.dart';
import '../info_widgets.dart';

class PredictiveChips extends StatelessWidget {
  final PredictionService pred;

  const PredictiveChips({super.key, required this.pred});

  @override
  Widget build(BuildContext context) {
    final chance = pred.currentConceptionChance;
    final daysToPeriod = pred.daysUntilNextPeriod;
    final daysToOvulation = pred.daysUntilOvulation;
    final nextPeriod = pred.nextPeriodDate;
    final avgLen = pred.averageCycleLength;
    final nextOvulation = pred.currentPeriodStart?.add(
      Duration(days: avgLen - 14),
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final chips = <_ChipData>[];

    chips.add(
      _ChipData(
        icon: Icons.favorite_rounded,
        label: 'Conception $chance%',
        color: colorScheme.primary,
        explanation: 'Your current estimated chance of conception is $chance%.',
        tip:
            chance > 20
                ? 'You are in or approaching your fertile window.'
                : 'Chances are currently low based on your cycle day.',
      ),
    );

    if (nextOvulation != null) {
      chips.add(
        _ChipData(
          icon: Icons.wb_sunny_rounded,
          label: 'Ovulation in ${daysToOvulation}d',
          color: colorScheme.secondary,
          explanation:
              'Ovulation is estimated to occur in $daysToOvulation days.',
          tip: 'This is usually your highest phase of energy and fertility.',
        ),
      );
    }

    if (nextPeriod != null) {
      chips.add(
        _ChipData(
          icon: Icons.calendar_today_rounded,
          label: 'Period in ${daysToPeriod}d',
          color: colorScheme.onSurface.withValues(alpha: 0.6),
          explanation:
              'Your next period is predicted to start in $daysToPeriod days.',
          tip: 'Log any PMS symptoms to improve future predictions.',
        ),
      );
    }

    if (daysToOvulation > 0 && daysToOvulation <= 5) {
      final peakIn = (daysToOvulation - 1).clamp(0, 5);
      chips.add(
        _ChipData(
          icon: Icons.auto_awesome_rounded,
          label: peakIn == 0 ? 'Peak today!' : 'Peak in ${peakIn}d',
          color: colorScheme.primary,
          explanation: 'Your fertility peak is very close.',
          tip:
              'Track your basal body temperature and cervical mucus for higher accuracy.',
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: chips.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = chips[i];
          return GestureDetector(
            onTap:
                () => showGlassInfoPopup(
                  context,
                  title: c.label,
                  explanation: c.explanation,
                  tip: c.tip,
                ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: c.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.color.withValues(alpha: 0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(c.icon, size: 14, color: c.color),
                  const SizedBox(width: 8),
                  Text(
                    c.label,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: c.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ChipData {
  final IconData icon;
  final String label;
  final Color color;
  final String explanation;
  final String tip;

  const _ChipData({
    required this.icon,
    required this.label,
    required this.color,
    required this.explanation,
    required this.tip,
  });
}

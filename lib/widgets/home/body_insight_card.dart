import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/prediction_service.dart';
import '../../utils/app_theme.dart';
import '../themed_container.dart';

class BodyInsightCard extends StatelessWidget {
  final PredictionService pred;

  const BodyInsightCard({super.key, required this.pred});

  @override
  Widget build(BuildContext context) {
    final phaseName = pred.phaseDisplayName;
    final day = pred.currentCycleDay == 0 ? 1 : pred.currentCycleDay;
    final biology = pred.getPhaseBiology(day);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final phaseColor = AppTheme.getPhaseColor(pred.currentPhase);

    return ThemedContainer(
      type: ContainerType.glass,
      padding: const EdgeInsets.all(24),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_rounded,
                    color: colorScheme.secondary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'YOUR BODY TODAY',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: phaseColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  phaseName.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: phaseColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _insightRow(
            context,
            '🧪',
            'HORMONES',
            biology['hormoneActivity'] ?? '',
            colorScheme.secondary,
          ),
          const Divider(height: 32, thickness: 0.5),
          _insightRow(
            context,
            '⚡',
            'ENERGY',
            biology['energy'] ?? '',
            Colors.orangeAccent,
          ),
          const Divider(height: 32, thickness: 0.5),
          _insightRow(
            context,
            '🧘',
            'MOOD',
            biology['mood'] ?? '',
            colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _insightRow(
    BuildContext context,
    String icon,
    String label,
    String text,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(icon, style: const TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: color,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

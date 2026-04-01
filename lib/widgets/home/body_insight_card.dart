import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/prediction_service.dart';
import '../../utils/app_theme.dart';
import '../glass_container.dart';

class BodyInsightCard extends StatelessWidget {
  final PredictionService pred;

  const BodyInsightCard({super.key, required this.pred});

  @override
  Widget build(BuildContext context) {
    final phaseName = pred.phaseDisplayName;
    final day = pred.currentCycleDay == 0 ? 1 : pred.currentCycleDay;
    final biology = pred.getPhaseBiology(day);
    final phaseColor = AppTheme.getPhaseColor(pred.currentPhase);

    return GlassContainer(
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
                  const Icon(
                    Icons.auto_awesome_rounded,
                    color: AppTheme.accentPurple,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'YOUR BODY TODAY',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textSecondary,
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
            '🧪',
            'HORMONES',
            biology['hormoneActivity'] ?? '',
            AppTheme.accentPurple,
          ),
          const Divider(height: 32, thickness: 0.5),
          _insightRow(
            '⚡',
            'ENERGY',
            biology['energy'] ?? '',
            Colors.orangeAccent,
          ),
          const Divider(height: 32, thickness: 0.5),
          _insightRow('🧘', 'MOOD', biology['mood'] ?? '', AppTheme.accentPink),
        ],
      ),
    );
  }

  Widget _insightRow(String icon, String label, String text, Color color) {
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
                  color: AppTheme.textDark,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../services/prediction_service.dart';
import '../themed_container.dart';

class DailyInsightCard extends StatelessWidget {
  final PredictionService pred;
  const DailyInsightCard({super.key, required this.pred});

  @override
  Widget build(BuildContext context) {
    final phase = pred.phaseDisplayName;
    final healthTips = AppTheme.getPhaseHealthTips(phase);
    final bio = pred.getPhaseBiology(pred.currentCycleDay);

    return ThemedContainer(
      type: ContainerType.glass,
      radius: 32,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.getPhaseColor(
                    pred.currentPhase,
                  ).withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.getPhaseColor(pred.currentPhase),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'DAILY INSIGHT',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            AppTheme.phaseTip(phase).headline,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            bio['hormoneActivity'] ?? '',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          
          // Energy & Mood Quick Status
          Row(
            children: [
              _statusChip(context, '⚡', bio['energy'] ?? '', Colors.orangeAccent),
              const SizedBox(width: 12),
              _statusChip(context, '🧘', bio['mood'] ?? '', Theme.of(context).colorScheme.primary),
            ],
          ),
          
          const Divider(height: 48, thickness: 0.5),

          _buildTipRow(
            context,
            Icons.restaurant_rounded,
            'Nutrition: ${healthTips.diet.first}',
          ),
          const SizedBox(height: 12),
          _buildTipRow(
            context,
            Icons.fitness_center_rounded,
            'Activity: ${healthTips.exercise.first}',
          ),
        ],
      ),
    );
  }

  Widget _statusChip(BuildContext context, String emoji, String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

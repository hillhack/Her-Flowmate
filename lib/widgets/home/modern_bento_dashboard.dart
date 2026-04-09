import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import '../../services/prediction_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';
import '../common/neu_card.dart';
import '../cycle_widgets.dart';
import 'cycle_core_ring.dart';
import 'daily_insight_card.dart';
import 'insight_bubble.dart';
import 'water_intake_card.dart';
import 'wellness_stats.dart';
import 'body_insight_card.dart';
import 'wellness_goals_card.dart';

class ModernBentoDashboard extends StatefulWidget {
  final StorageService storage;
  final PredictionService pred;
  final ConfettiController confettiController;

  const ModernBentoDashboard({
    super.key,
    required this.storage,
    required this.pred,
    required this.confettiController,
  });

  @override
  State<ModernBentoDashboard> createState() => _ModernBentoDashboardState();
}

class _ModernBentoDashboardState extends State<ModernBentoDashboard> {
  bool _isHormonesExpanded = false;
  bool _isWaterExpanded = false;
  bool _isSleepExpanded = false;
  bool _isStreakExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        return Column(
          children: [
            // ── 1. Top 3-metric summary cards ──────────────────────────
            _buildTopMetricsRow(),
            const SizedBox(height: AppDesignTokens.space24),

            // ── 2. Cycle Core Ring (primary progress gauge) ────────────
            RepaintBoundary(
              child: CycleCoreRing(pred: widget.pred)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.9, 0.9)),
            ),
            const SizedBox(height: 24),

            // ── 3. Daily Phase Insight Card ─────────────────────────────
            RepaintBoundary(
              child: DailyInsightCard(pred: widget.pred)
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideY(begin: 0.1),
            ),
            const SizedBox(height: 32),

            // ── 4. Expandable Quick-access Insight Bubbles ──────────────
            _buildInsightBubbles(isWide),
            const SizedBox(height: 24),

            // ── 5. Expanded detail panels ───────────────────────────────
            if (_isHormonesExpanded)
              ...[
                HormoneGraph(pred: widget.pred),
                const SizedBox(height: 16),
                PhaseHealthTipsWidget(pred: widget.pred),
                const SizedBox(height: 16),
              ].animate().fadeIn().slideY(begin: -0.05),

            if (_isWaterExpanded)
              RepaintBoundary(
                child: WaterIntakeCard(
                  storage: widget.storage,
                  onGoalReached: () {
                    if (mounted) widget.confettiController.play();
                  },
                ).animate().fadeIn().slideY(begin: -0.05),
              ),

            if (_isSleepExpanded)
              SleepCard(
                storage: widget.storage,
                pred: widget.pred,
              ).animate().fadeIn().slideY(begin: -0.05),

            if (_isStreakExpanded)
              RepaintBoundary(
                child: StreakCard(
                  storage: widget.storage,
                  onMilestoneReached: () {
                    if (mounted) widget.confettiController.play();
                  },
                ).animate().fadeIn().slideY(begin: -0.05),
              ),

            // ── 6. Your Body Today (Hormones / Energy / Mood) ──────────
            const SizedBox(height: 16),
            BodyInsightCard(pred: widget.pred),

            // ── 7. Wellness Goals / upcoming reminders ──────────────────
            const SizedBox(height: 24),
            WellnessGoalsCard(
              storage: widget.storage,
              heroTag: 'wellness_goals_bento',
            ),
          ],
        );
      },
    );
  }

  // ── Top metrics row ────────────────────────────────────────────────────────

  Widget _buildTopMetricsRow() {
    final day = widget.pred.currentCycleDay == 0
        ? 1
        : widget.pred.currentCycleDay;
    final nextPeriodDays = widget.pred.nextPeriodDate != null
        ? widget.pred.nextPeriodDate!.difference(DateTime.now()).inDays
        : -1;
    final nextStr = nextPeriodDays > 0
        ? 'in $nextPeriodDays d'
        : (nextPeriodDays == 0 ? 'Today' : 'Due');

    return Row(
      children: [
        Expanded(
          child: _metricCard(label: 'Cycle day', value: '$day', delay: 0),
        ),
        const SizedBox(width: AppDesignTokens.space8),
        Expanded(
          child: _metricCard(
            label: 'Next period',
            value: nextStr,
            delay: 100,
          ),
        ),
        const SizedBox(width: AppDesignTokens.space8),
        Expanded(
          child: _metricCard(
            label: 'Phase',
            value: widget.pred.phaseDisplayName,
            delay: 200,
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required String label,
    required String value,
    required int delay,
  }) {
    return NeumorphicCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.1);
  }

  // ── Insight Bubbles ────────────────────────────────────────────────────────

  Widget _buildInsightBubbles(bool isWide) {
    final bubbles = [
      _bubble(
        icon: '🧪',
        label: 'Hormones',
        color: Theme.of(context).colorScheme.primary,
        isExpanded: _isHormonesExpanded,
        onTap: () =>
            setState(() => _isHormonesExpanded = !_isHormonesExpanded),
      ),
      _bubble(
        icon: '💧',
        label: 'Water',
        color: Colors.blueAccent,
        isExpanded: _isWaterExpanded,
        onTap: () => setState(() => _isWaterExpanded = !_isWaterExpanded),
      ),
      _bubble(
        icon: '🌙',
        label: 'Sleep',
        color: const Color(0xFF66BB6A),
        isExpanded: _isSleepExpanded,
        onTap: () => setState(() => _isSleepExpanded = !_isSleepExpanded),
      ),
      _bubble(
        icon: '🔥',
        label: 'Streak',
        color: Theme.of(context).colorScheme.secondary,
        isExpanded: _isStreakExpanded,
        onTap: () => setState(() => _isStreakExpanded = !_isStreakExpanded),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 0 : 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: bubbles.map((b) => Expanded(child: b)).toList(),
      ),
    );
  }

  Widget _bubble({
    required String icon,
    required String label,
    required Color color,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return InsightBubble(
      icon: icon,
      label: label,
      color: color,
      isExpanded: isExpanded,
      onTap: onTap,
    );
  }
}

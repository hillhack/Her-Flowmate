import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../../services/prediction_service.dart';
import '../../services/storage_service.dart';
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
            RepaintBoundary(
              child: CycleCoreRing(pred: widget.pred)
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.9, 0.9)),
            ),
            const SizedBox(height: 24),
            RepaintBoundary(
              child: DailyInsightCard(
                pred: widget.pred,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
            ),
            const SizedBox(height: 32),
            _buildResponsiveInsightBubbles(isWide),
            const SizedBox(height: 24),
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
                  onGoalReached: () => widget.confettiController.play(),
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
                  onMilestoneReached: () => widget.confettiController.play(),
                ).animate().fadeIn().slideY(begin: -0.05),
              ),
            const SizedBox(height: 16),
            BodyInsightCard(pred: widget.pred),
            const SizedBox(height: 24),
            WellnessGoalsCard(storage: widget.storage),
          ],
        );
      },
    );
  }

  Widget _buildResponsiveInsightBubbles(bool isWide) {
    final bubbles = [
      _bubble(
        icon: '🧪',
        label: 'Hormones',
        color: Theme.of(context).colorScheme.primary,
        isExpanded: _isHormonesExpanded,
        onTap: () => setState(() => _isHormonesExpanded = !_isHormonesExpanded),
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

    if (isWide) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: bubbles.map((b) => Expanded(child: b)).toList(),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: bubbles.map((b) => Expanded(child: b)).toList(),
        ),
      );
    }
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

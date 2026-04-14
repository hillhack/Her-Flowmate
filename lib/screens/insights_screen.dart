import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../models/period_log.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';
import '../widgets/shared_app_bar.dart';
import '../widgets/cycle_widgets.dart';


class InsightsScreen extends StatefulWidget {
  final VoidCallback? onMenuPressed;
  const InsightsScreen({super.key, this.onMenuPressed});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {

  @override
  Widget build(BuildContext context) {
    final pred = context.watch<PredictionService>();
    final storage = context.watch<StorageService>();
    final logs = storage.getLogs();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: SharedAppBar(
        title: 'Cycle Insights',
        onMenuPressed: widget.onMenuPressed,
      ),
      body: Container(
        decoration: AppTheme.getBackgroundDecoration(context),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            top: kToolbarHeight + MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            bottom: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFlowmateScore(pred).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 24),

              Text(
                'Cycle Statistics',
                style: AppTheme.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildScoreCard(
                      'Avg Cycle',
                      '${pred.averageCycleLength}d',
                      Icons.sync_rounded,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildScoreCard(
                      'Avg Period',
                      '${_getAveragePeriodLength(logs)}d',
                      Icons.water_drop_rounded,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.05),
              const SizedBox(height: 32),

              const _DailyInsightCard().animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),
              const SizedBox(height: 32),

              Text(
                'Wellness Advice',
                style: AppTheme.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: context.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              PhaseHealthTipsWidget(pred: pred).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }


  int _getAveragePeriodLength(List<PeriodLog> logs) {
    if (logs.isEmpty) return 5;
    int total = logs.fold(0, (sum, log) => sum + log.duration);
    return (total / logs.length).round();
  }

  Widget _buildScoreCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.accentPink.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.accentPink, size: 24),
          const SizedBox(height: 16),
          Text(value, style: AppTheme.playfair(fontSize: 26, fontWeight: FontWeight.w900, color: context.onSurface)),
          Text(title, style: AppTheme.outfit(fontSize: 12, color: context.secondaryText, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFlowmateScore(PredictionService pred) {
    int score = _computeFlowmateScore(pred);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.accentPink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.accentPink.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flowmate Score', style: AppTheme.outfit(fontSize: 14, fontWeight: FontWeight.w700, color: context.secondaryText)),
                Text('$score', style: AppTheme.playfair(fontSize: 48, fontWeight: FontWeight.w900, color: context.onSurface)),
                const SizedBox(height: 8),
                Text(
                  'Your daily health index based on symptoms and regularity.',
                  style: AppTheme.outfit(fontSize: 13, color: context.secondaryText),
                ),
              ],
            ),
          ),
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(color: AppTheme.accentPink.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentPink, size: 32),
          ),
        ],
      ),
    );
  }

  int _computeFlowmateScore(PredictionService pred) {
    int base = pred.getHealthScore();
    final avg = pred.averageCycleLength;
    if (avg >= 21 && avg <= 35) base = (base + 10).clamp(0, 100);
    return base;
  }
}


class _DailyInsightCard extends StatelessWidget {
  const _DailyInsightCard();

  static const List<String> _tips = [
    "Regular exercise can help reduce menstrual cramps by improving blood flow.",
    "Stay hydrated! Drinking water helps reduce bloating during your cycle.",
    "Iron-rich foods like spinach and lentils are great during your menstrual phase.",
    "The follicular phase is often when your energy and creativity peak.",
    "Your body requires more rest during the luteal phase. Listen to it!",
    "Magnesium-rich foods like bananas can help with PMS symptoms.",
    "Tracking symptoms helps identify your own unique cycle patterns.",
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final tip = _tips[dayOfYear % _tips.length];

    return ThemedContainer(
      type: ContainerType.neu,
      radius: 28,
      padding: const EdgeInsets.all(20),
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            const Text('💡', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Insight',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentPink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    tip,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: context.onSurface,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

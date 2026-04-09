import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/prediction_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';
import '../../screens/daily_checkin_screen.dart';
import '../common/neu_card.dart';
import '../common/primary_button.dart';
import '../../models/period_log.dart';

class TTCDashboard extends StatelessWidget {
  final StorageService storage;
  final PredictionService pred;

  // Fertility Thresholds
  static const double peakFertilityThreshold = 25.0;
  static const double approachingFertilityThreshold = 10.0;

  const TTCDashboard({super.key, required this.storage, required this.pred});

  @override
  Widget build(BuildContext context) {
    if (pred.currentCycleDay == 0 || pred.averageCycleLength == 0) {
      return Padding(
        padding: const EdgeInsets.all(AppDesignTokens.space24),
        child: Center(
          child: Text(
            'Log your period to see fertility insights',
            style: AppTheme.outfit(context: context, fontSize: AppDesignTokens.bodyLargeSize),
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildTopMetricsRow(context),
        const SizedBox(height: AppDesignTokens.space24),
        _buildPrimaryInsight(context),
        const SizedBox(height: AppDesignTokens.space24),
        _buildConceptionTipsCard(context, pred),
        const SizedBox(height: AppDesignTokens.space24),
        _buildCallToAction(context),
        const SizedBox(height: AppDesignTokens.space24),
        _buildRecentActivity(context),
      ],
    );
  }

  Widget _buildTopMetricsRow(BuildContext context) {
    final ovDays = pred.daysUntilOvulation;
    final ovStr =
        ovDays == 0 ? 'Today' : (ovDays > 0 ? 'in $ovDays d' : 'Passed');

    // Estimate fertile window dates: approx 5 days before ovulation
    final today = DateTime.now();
    final ovDate = today.add(Duration(days: ovDays > 0 ? ovDays : 0));
    final windowStart = ovDate.subtract(const Duration(days: 5));
    final windowEnd = ovDate.add(const Duration(days: 1));

    String windowText =
        '${DateFormat('MMM d').format(windowStart)} - ${DateFormat('MMM d').format(windowEnd)}';
    if (ovDays < 0) windowText = 'TBD';

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 360) {
          return Column(
            children: [
              _metricCard(context, label: 'Fertile Window', value: windowText, delay: 0),
              const SizedBox(height: AppDesignTokens.space8),
              _metricCard(context, label: 'Ovulation', value: ovStr, delay: 100),
              const SizedBox(height: AppDesignTokens.space8),
              _metricCard(context, label: 'Peak Fertility', value: '${pred.currentConceptionChance}%', delay: 200),
            ],
          );
        }
        return Row(
          children: [
            Expanded(
              child: _metricCard(
                context,
                label: 'Fertile Window',
                value: windowText,
                delay: 0,
              ),
            ),
            const SizedBox(width: AppDesignTokens.space8),
            Expanded(
              child: _metricCard(
                context,
                label: 'Ovulation',
                value: ovStr,
                delay: 100,
              ),
            ),
            const SizedBox(width: AppDesignTokens.space8),
            Expanded(
              child: _metricCard(
                context,
                label: 'Peak Fertility',
                value: '${pred.currentConceptionChance}%',
                delay: 200,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _metricCard(
    BuildContext context, {
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
              fontSize: AppDesignTokens.labelSize,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDesignTokens.space4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: AppDesignTokens.bodySize,
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

  Widget _buildPrimaryInsight(BuildContext context) {
    final int todayChance = pred.currentConceptionChance;

    return NeumorphicCard(
      padding: const EdgeInsets.all(AppDesignTokens.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Fertility Timeline',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: AppDesignTokens.bodySize,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesignTokens.space24),
          _buildFertileBar(context),
          const SizedBox(height: AppDesignTokens.space16),
          Text(
            todayChance >= peakFertilityThreshold
                ? 'Today is highly fertile! Great day to try.'
                : 'Keep tracking to uncover your full fertile window.',
            style: GoogleFonts.inter(
              fontSize: AppDesignTokens.bodySize - 1,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildFertileBar(BuildContext context) {
    final today = DateTime.now();
    List<Widget> barSegments = [];

    for (int i = -4; i <= 6; i++) {
      DateTime d = today.add(Duration(days: i));
      int chance = pred.getConceptionChance(d);

      Color segmentColor;
      if (chance >= peakFertilityThreshold) {
        segmentColor = Theme.of(context).colorScheme.primary; // Peak
      } else if (chance >= approachingFertilityThreshold) {
        segmentColor = Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: 0.4); // High
      } else {
        segmentColor = Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.1); // Low
      }

      barSegments.add(
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            height: i == 0 ? 32 : 24, // Taller for today
            decoration: BoxDecoration(
              color: segmentColor,
              borderRadius: BorderRadius.circular(4),
              border: i == 0 ? Border.all(color: Colors.white, width: 2) : null,
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: barSegments,
    );
  }

  Widget _buildCallToAction(BuildContext context) {
    return PrimaryButton(
      label: 'Log symptoms or intercourse',
      icon: Icons.add_rounded,
      onTap: () {
        HapticFeedback.lightImpact();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder:
              (context) => Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: const DailyCheckinScreen(),
              ),
        );
      },
    ).animate().fadeIn(delay: 400.ms).scale();
  }

  Widget _buildRecentActivity(BuildContext context) {
    final logs = storage.getLogs();
    if (logs.isEmpty) return const SizedBox.shrink();

    final sortedLogs = List<PeriodLog>.from(logs)
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
    final recentLogs = sortedLogs.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Logged:',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: AppDesignTokens.bodySize,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        ...recentLogs.map(
          (log) => Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                Text(
                  '• ',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('MMM d').format(log.startDate),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: AppDesignTokens.bodySize - 1,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  ' - Logged Activity',
                  style: GoogleFonts.inter(
                    fontSize: AppDesignTokens.bodySize - 1,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildConceptionTipsCard(BuildContext context, PredictionService pred) {
    final chance = pred.currentConceptionChance;
    final day = pred.currentCycleDay;

    String title = 'Keep tracking!';
    String tip =
        'Logging your daily symptoms helps us predict your fertile window more accurately.';
    IconData icon = Icons.auto_awesome_rounded;

    if (chance >= peakFertilityThreshold) {
      title = 'Peak Fertility! ✨';
      tip =
          'You are in your most fertile window. This is the best time for intimacy if you are trying to conceive.';
      icon = Icons.favorite_rounded;
    } else if (chance >= approachingFertilityThreshold) {
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

    final phaseColor = AppTheme.getPhaseColor(pred.currentPhase);

    return Semantics(
      label: 'Conception tips: $title. $tip',
      child: NeumorphicCard(
        padding: const EdgeInsets.all(AppDesignTokens.space24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 360) {
              return Column(
                children: [
                  _TipIcon(icon: icon, color: phaseColor),
                  const SizedBox(height: AppDesignTokens.space16),
                  _TipTexts(title: title, tip: tip),
                ],
              );
            }
            return Row(
              children: [
                _TipIcon(icon: icon, color: phaseColor),
                const SizedBox(width: AppDesignTokens.space20),
                Expanded(child: _TipTexts(title: title, tip: tip)),
              ],
            );
          },
        ),
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1);
  }
}

class _TipIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _TipIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDesignTokens.space12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 28,
      ),
    );
  }
}

class _TipTexts extends StatelessWidget {
  final String title;
  final String tip;

  const _TipTexts({required this.title, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const SizedBox(height: AppDesignTokens.space4),
        Text(
          tip,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

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
import 'dashboard_calendar_strip.dart';
import 'conception_wheel.dart';

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
            style: AppTheme.outfit(
              context: context,
              fontSize: AppDesignTokens.bodyLargeSize,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // ── 1. Interactive Calendar Strip (Central Focus) ─────────────
        DashboardCalendarStrip(
          pred: pred,
          storage: storage,
          onDateSelected: (date) {
            // Future: Open fertility details for that date
          },
        ).animate().slideY(begin: 0.1, duration: 400.ms),
        const SizedBox(height: AppDesignTokens.space24),

        _buildWheelInsight(context),
        const SizedBox(height: AppDesignTokens.space24),
        _buildConceptionTipsCard(context, pred),
        const SizedBox(height: AppDesignTokens.space24),
        _buildCallToAction(context),
        const SizedBox(height: AppDesignTokens.space24),
        _buildRecentActivity(context),
      ],
    );
  }

  Widget _buildWheelInsight(BuildContext context) {
    return NeumorphicCard(
      padding: const EdgeInsets.symmetric(vertical: AppDesignTokens.space32),
      child: Center(
        child: ConceptionWheel(
          pred: pred,
        ).animate().scaleXY(begin: 0.9, duration: 400.ms),
      ),
    ).animate().slideY(begin: 0.1, delay: 300.ms);
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
    ).animate().scale(delay: 400.ms);
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
    ).animate().slideY(begin: 0.1, delay: 500.ms);
  }

  Widget _buildConceptionTipsCard(
    BuildContext context,
    PredictionService pred,
  ) {
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
    ).animate().slideY(begin: 0.1, delay: 400.ms);
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
      child: Icon(icon, color: color, size: 28),
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
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

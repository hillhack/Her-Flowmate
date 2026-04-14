import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';
import '../models/daily_log.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';
import 'log_period_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final logs = storage.getLogs();

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
          ),
          _buildDreamyBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Static Top Bar ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 24,
                    bottom: 16,
                  ),
                  child: Row(
                    children: [
                      ThemedContainer(
                        type: ContainerType.neu,
                        padding: const EdgeInsets.all(12),
                        radius: 16,
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: AppTheme.accentPink,
                          size: 26,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Cycle History',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    color: AppTheme.accentPink,
                    onRefresh: () async {
                      HapticFeedback.mediumImpact();
                      await Future.delayed(const Duration(milliseconds: 1500));
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        // ── Trend Chart ──────────────────────────────────────────
                        if (logs.length > 1)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: ThemedContainer(
                                type: ContainerType.glass,
                                radius: 32,
                                child: Padding(
                                  padding: const EdgeInsets.all(28),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cycle Duration Trend',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        height: 200,
                                        child: LineChart(
                                          LineChartData(
                                            gridData: const FlGridData(
                                              show: false,
                                            ),
                                            titlesData: FlTitlesData(
                                              show: true,
                                              bottomTitles: AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: true,
                                                  getTitlesWidget: (
                                                    value,
                                                    meta,
                                                  ) {
                                                    if (value.toInt() >= 0 &&
                                                        value.toInt() <
                                                            logs.length) {
                                                      final date =
                                                          logs[value.toInt()]
                                                              .startDate;
                                                      return Padding(
                                                        padding:
                                                            const EdgeInsets.only(
                                                              top: 8,
                                                            ),
                                                        child: Text(
                                                          DateFormat(
                                                            'Md',
                                                          ).format(date),
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 10,
                                                              ),
                                                        ),
                                                      );
                                                    }
                                                    return const SizedBox();
                                                  },
                                                ),
                                              ),
                                              topTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              rightTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                              leftTitles: const AxisTitles(
                                                sideTitles: SideTitles(
                                                  showTitles: false,
                                                ),
                                              ),
                                            ),
                                            borderData: FlBorderData(
                                              show: false,
                                            ),
                                            lineBarsData: [
                                              LineChartBarData(
                                                spots:
                                                    logs.reversed
                                                        .toList()
                                                        .asMap()
                                                        .entries
                                                        .map((e) {
                                                          return FlSpot(
                                                            e.key.toDouble(),
                                                            e.value.duration
                                                                .toDouble(),
                                                          );
                                                        })
                                                        .toList(),
                                                isCurved: true,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                barWidth: 4,
                                                isStrokeCapRound: true,
                                                dotData: const FlDotData(
                                                  show: true,
                                                ),
                                                belowBarData: BarAreaData(
                                                  show: true,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                      .withValues(alpha: 0.1),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          ),

                        // ── Log List ─────────────────────────────────────────────────
                        if (logs.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(48),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ThemedContainer(
                                          type: ContainerType.glass,
                                          padding: const EdgeInsets.all(32),
                                          radius: 48,
                                          child: const Icon(
                                                Icons
                                                    .history_toggle_off_rounded,
                                                color: AppTheme.accentPink,
                                                size: 64,
                                              )
                                              .animate(
                                                onPlay:
                                                    (c) =>
                                                        c.repeat(reverse: true),
                                              )
                                              .scaleXY(
                                                begin: 1.0,
                                                end: 1.1,
                                                duration: 1500.ms,
                                                curve: Curves.easeInOut,
                                              )
                                              .shimmer(
                                                duration: 2000.ms,
                                                color: Colors.white,
                                              ),
                                        )
                                        .animate()
                                        .fadeIn(duration: 800.ms)
                                        .scaleXY(begin: 0.8),
                                    const SizedBox(height: 32),
                                    Text(
                                      'No data recorded yet.',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    ElevatedButton.icon(
                                      onPressed:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) =>
                                                      const LogPeriodScreen(),
                                            ),
                                          ),
                                      icon: const Icon(
                                        Icons.add_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      label: Text(
                                        'Log your first period',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.accentPink,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((ctx, i) {
                                final log = logs[i];
                                final dailyLog = storage.getDailyLog(
                                  log.startDate,
                                );

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: ThemedContainer(
                                    type: ContainerType.glass,
                                    radius: 28,
                                    onTap:
                                        dailyLog != null
                                            ? () => _showDailyLogDetails(
                                              context,
                                              dailyLog,
                                            )
                                            : null,
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.water_drop_rounded,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                size: 28,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      DateFormat(
                                                        'MMM d, yyyy',
                                                      ).format(log.startDate),
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color:
                                                                AppTheme
                                                                    .textDark,
                                                          ),
                                                    ),
                                                    if (log.flowIntensity !=
                                                        null) ...[
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color:
                                                              log.flowIntensity ==
                                                                      'Heavy'
                                                                  ? Colors
                                                                      .redAccent
                                                                  : log.flowIntensity ==
                                                                      'Medium'
                                                                  ? AppTheme
                                                                      .accentPink
                                                                  : AppTheme
                                                                      .primaryPink300,
                                                        ),
                                                      ),
                                                    ],
                                                    if (dailyLog != null) ...[
                                                      const SizedBox(width: 8),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(
                                                                context,
                                                              )
                                                              .colorScheme
                                                              .primary
                                                              .withValues(
                                                                alpha: 0.1,
                                                              ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                        ),
                                                        child: Icon(
                                                          Icons
                                                              .assignment_turned_in_rounded,
                                                          size: 14,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    Text(
                                                      '${log.duration} days',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        color:
                                                            AppTheme
                                                                .textSecondary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    if (log.mood != null) ...[
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        '•',
                                                        style: TextStyle(
                                                          color: AppTheme
                                                              .textSecondary
                                                              .withValues(
                                                                alpha: 0.5,
                                                              ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        log.mood!,
                                                        style: GoogleFonts.inter(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            dailyLog != null
                                                ? Icons
                                                    .keyboard_arrow_down_rounded
                                                : Icons.chevron_right_rounded,
                                            color: AppTheme.textSecondary,
                                            size: 28,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ).animate().fadeIn(
                                  delay: Duration(milliseconds: 100 * i),
                                );
                              }, childCount: logs.length),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDailyLogDetails(BuildContext context, DailyLog log) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: AppTheme.frameColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
            ),
            padding: const EdgeInsets.only(top: 16),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(40),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.textSecondary.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Details for ${DateFormat('MMM d').format(log.date)}',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildDetailRow(
                        'Flow Intensity',
                        log.flowIntensity ?? 'Normal',
                      ),
                      _buildDetailRow('Mood', log.moods?.join(', ') ?? 'Good'),
                      _buildDetailRow(
                        'Water Intake',
                        '${log.waterIntake} cups',
                      ),
                      _buildDetailRow('Sleep', '${log.sleepHours} hours'),
                      if (log.symptoms != null && log.symptoms!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Symptoms',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              log.symptoms!
                                  .map(
                                    (s) => Chip(
                                      label: Text(s),
                                      backgroundColor: AppTheme.accentPink
                                          .withValues(alpha: 0.1),
                                      side: BorderSide.none,
                                    ),
                                  )
                                  .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDreamyBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentPink.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentPurple.withValues(alpha: 0.03),
            ),
          ),
        ),
      ],
    );
  }
}

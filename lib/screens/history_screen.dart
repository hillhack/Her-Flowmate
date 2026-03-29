import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';
import '../models/daily_log.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';
import '../widgets/neu_container.dart';

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
                      NeuContainer(
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
                              color: AppTheme.midnightPlum,
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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // ── Trend Chart ──────────────────────────────────────────
                        if (logs.length > 1)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            child: GlassContainer(
                              radius: 32,
                              child: Padding(
                                padding: const EdgeInsets.all(28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          titlesData: const FlTitlesData(
                                            show: false,
                                          ),
                                          borderData: FlBorderData(show: false),
                                          lineBarsData: [
                                            LineChartBarData(
                                              spots:
                                                  logs
                                                      .asMap()
                                                      .entries
                                                      .map(
                                                        (e) => FlSpot(
                                                          e.key.toDouble(),
                                                          e.value.duration
                                                              .toDouble(),
                                                        ),
                                                      )
                                                      .toList(),
                                              isCurved: true,
                                              color: AppTheme.accentPink,
                                              barWidth: 4,
                                              isStrokeCapRound: true,
                                              dotData: const FlDotData(
                                                show: true,
                                              ),
                                              belowBarData: BarAreaData(
                                                show: true,
                                                color: AppTheme.accentPink
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

                        // ── Log List ─────────────────────────────────────────────────
                        if (logs.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(48),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const GlassContainer(
                                  padding: EdgeInsets.all(32),
                                  radius: 48,
                                  child: Icon(
                                    Icons.history_toggle_off_rounded,
                                    color: AppTheme.accentPink,
                                    size: 64,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  'No data recorded yet.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
                            itemCount: logs.length,
                            itemBuilder: (ctx, i) {
                              final log =
                                  logs[logs.length - 1 - i]; // Latest first
                              final dailyLog = storage.getDailyLog(
                                log.startDate,
                              );

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: GlassContainer(
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
                                            color: AppTheme.accentPink
                                                .withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.water_drop_rounded,
                                              color: AppTheme.accentPink,
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
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color:
                                                          AppTheme.midnightPlum,
                                                    ),
                                                  ),
                                                  if (dailyLog != null) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppTheme
                                                            .accentPink
                                                            .withValues(
                                                              alpha: 0.1,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .assignment_turned_in_rounded,
                                                        size: 14,
                                                        color:
                                                            AppTheme.accentPink,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 4),
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
                                                            AppTheme.accentPink,
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
                            },
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
                          width: 48,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(
                              0x339E9E9E,
                            ), // Approximate textSecondary 0.2
                            borderRadius: BorderRadius.all(Radius.circular(3)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          const NeuContainer(
                            padding: EdgeInsets.all(12),
                            radius: 16,
                            child: Icon(
                              Icons.assignment_rounded,
                              color: AppTheme.accentPink,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Daily Check-in',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.midnightPlum,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'EEEE, MMM d, yyyy',
                                  ).format(log.date),
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                            color: AppTheme.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // ── Mood & Symptoms ───────────────────────────────────────
                      if ((log.moods?.isNotEmpty ?? false) ||
                          (log.symptoms?.isNotEmpty ?? false))
                        _buildSection(
                          'Feeling',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (log.moods?.isNotEmpty ?? false)
                                Wrap(
                                  spacing: 8,
                                  children:
                                      log.moods!
                                          .map<Widget>(
                                            (m) => _buildChip(
                                              m,
                                              AppTheme.accentPink,
                                            ),
                                          )
                                          .toList(),
                                ),
                              if (log.symptoms?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      log.symptoms!
                                          .map<Widget>(
                                            (s) => _buildChip(
                                              s,
                                              const Color(0xFFBA68C8),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ],
                            ],
                          ),
                        ),

                      // ── Flow Intensity ─────────────────────────────────────────
                      if (log.flowIntensity != null)
                        _buildSection(
                          'Flow Intensity',
                          _buildChip(log.flowIntensity!, AppTheme.accentPink),
                        ),

                      // ── Water & Activity ───────────────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (log.waterIntake != null && log.waterIntake! > 0)
                            Expanded(
                              child: _buildSection(
                                'Hydration',
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.water_drop_rounded,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${log.waterIntake} glasses',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (log.physicalActivity?.isNotEmpty ?? false)
                            Expanded(
                              child: _buildSection(
                                'Activity',
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      log.physicalActivity!
                                          .map<Widget>(
                                            (a) => _buildChip(
                                              a,
                                              const Color(0xFF81C784),
                                            ),
                                          )
                                          .toList(),
                                ),
                              ),
                            ),
                        ],
                      ),

                      // ── Notes ─────────────────────────────────────────
                      if (log.notes?.isNotEmpty ?? false)
                        _buildSection(
                          'Notes',
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              color: Color(0x80FFFFFF), // Approximate white 0.5
                              borderRadius: BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                            child: Text(
                              log.notes!,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: AppTheme.textDark,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
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

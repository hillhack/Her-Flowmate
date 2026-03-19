import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/glass_container.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.watch<StorageService>();
    final logs = storage.getLogs();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Text(
              'Cycle History',
              style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark),
              textAlign: TextAlign.center,
            ).animate().fadeIn(),
          ),

          // ── Trend Chart ──────────────────────────────────────────────
          if (logs.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: GlassContainer(
                radius: 28,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cycle Duration Trend',
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textDark.withOpacity(0.6))),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: LineChart(LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: logs.asMap().entries
                                  .map((e) => FlSpot(e.key.toDouble(),
                                      e.value.duration.toDouble()))
                                  .toList(),
                              isCurved: true,
                              color: AppTheme.accentPink,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppTheme.accentPink.withOpacity(0.15),
                              ),
                            ),
                          ],
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

          // ── Log List ─────────────────────────────────────────────────
          if (logs.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      radius: 40,
                      child: const Icon(Icons.history_toggle_off_rounded,
                          color: AppTheme.accentPink, size: 56),
                    ),
                    const SizedBox(height: 24),
                    Text('No data recorded yet.',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark.withOpacity(0.5))),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                itemCount: logs.length,
                itemBuilder: (ctx, i) {
                  final log = logs[logs.length - 1 - i]; // Latest first
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassContainer(
                      radius: 24,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(
                                color: AppTheme.accentPink.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(Icons.water_drop_rounded,
                                    color: AppTheme.accentPink, size: 24),
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('MMM d, yyyy').format(log.startDate),
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        '${log.duration} days long',
                                        style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: AppTheme.textDark.withOpacity(0.6)),
                                      ),
                                      if (log.mood != null) ...[
                                        const SizedBox(width: 8),
                                        Text('•', style: TextStyle(color: AppTheme.textDark.withOpacity(0.3))),
                                        const SizedBox(width: 8),
                                        Text(log.mood!, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.accentPink)),
                                      ],
                                    ],
                                  ),
                                  if (log.symptoms != null && log.symptoms!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: log.symptoms!.map((s) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentPink.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppTheme.accentPink.withOpacity(0.1)),
                                        ),
                                        child: Text(s, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.accentPink, fontWeight: FontWeight.w500)),
                                      )).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppTheme.textDark, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: Duration(milliseconds: 100 * i));
                },
              ),
            ),
        ],
      ),
    );
  }
}

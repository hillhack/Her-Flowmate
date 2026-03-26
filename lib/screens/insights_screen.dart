import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../models/period_log.dart';
import '../utils/app_theme.dart';
import '../widgets/cycle_phase_wheel.dart';
import '../widgets/neu_container.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pred = context.watch<PredictionService>();
    final storage = context.watch<StorageService>();
    final logs = storage.getLogs();

    final cycleDay = pred.currentCycleDay == 0 ? 1 : pred.currentCycleDay;
    final cycleLen = pred.averageCycleLength > 0 ? pred.averageCycleLength : 28;
    final phaseName = pred.phaseDisplayName;
    final daysToNext = pred.daysUntilNextPeriod;

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: NeuContainer(
              radius: 12,
              padding: EdgeInsets.zero,
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
            ),
          ),
        ),
        title: Text(
          'Cycle Insights',
          style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.w800, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Changed to stretch for charts
            children: [
              // Large Phase Wheel
              CyclePhaseWheel(
                currentCycleDay: cycleDay,
                cycleLength: cycleLen,
                currentPhase: phaseName,
                daysUntilNextPeriod: daysToNext,
              ).animate().fadeIn(duration: 800.ms).scale(curve: Curves.easeOutBack),

              const SizedBox(height: 40),
              const _DailyInsightCard().animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 32),

              // Scores Row
              Row(
                children: [
                  Expanded(child: _buildScoreCard('Avg Cycle', '${pred.averageCycleLength}d', Icons.sync_rounded)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildScoreCard('Avg Period', '${_getAveragePeriodLength(logs)}d', Icons.water_drop_rounded)),
                ],
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              // Data Visualizations
              Text('Cycle History', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)).animate().fadeIn(delay: 550.ms),
              const SizedBox(height: 16),
              _buildCycleChart(logs).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
              
              const SizedBox(height: 32),
              
              _buildFlowmateScore(pred).animate().fadeIn(delay: 650.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),
              
              Text('Symptom Frequency', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark)).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 16),
              _buildSymptomStats(logs).animate().fadeIn(delay: 750.ms).slideY(begin: 0.1),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  int _getAveragePeriodLength(List<PeriodLog> logs) {
    if (logs.isEmpty) return 5;
    int total = 0;
    for (var log in logs) {
      total += log.duration;
    }
    return (total / logs.length).round();
  }

  Widget _buildScoreCard(String title, String value, IconData icon) {
    return NeuContainer(
      radius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.accentPink.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.accentPink, size: 24),
          ),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
          Text(title, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFlowmateScore(PredictionService pred) {
    final isRegular = !pred.isIrregularCycle;
    final score = isRegular ? 95 : 72;
    
    return NeuContainer(
      radius: 28,
      padding: const EdgeInsets.all(24),
      borderColor: AppTheme.accentPink.withOpacity(0.3),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Flowmate Score', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '$score',
                  style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w900, color: AppTheme.textDark, height: 1.0),
                ),
                const SizedBox(height: 8),
                Text(
                  isRegular ? 'Your cycle is highly regular. Keep logging!' : 'Your cycle shows some variation. This is normal!',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentPink.withOpacity(0.1),
            ),
            child: Center(
              child: Icon(isRegular ? Icons.check_circle_rounded : Icons.info_rounded, color: AppTheme.accentPink, size: 40),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCycleChart(List<PeriodLog> logs) {
    List<int> cycleLengths = [];
    for (int i = 0; i < logs.length - 1 && cycleLengths.length < 6; i++) {
      final currentStart = logs[i].startDate;
      final previousStart = logs[i+1].startDate;
      final diff = previousStart.difference(currentStart).inDays.abs();
      if (diff > 15 && diff < 90) cycleLengths.insert(0, diff); // Reverse for chronological order
    }

    return NeuContainer(
      radius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Last Cycles (Days)', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: cycleLengths.isEmpty 
                ? Center(child: Text('Log more periods to see chart', style: GoogleFonts.inter(color: AppTheme.textSecondary)))
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceEvenly,
                          maxY: 40,
                          minY: 0,
                          groupsSpace: 12,
                          barTouchData: BarTouchData(
                            touchTooltipData: BarTouchTooltipData(
                              getTooltipColor: (_) => AppTheme.textDark,
                              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                return BarTooltipItem(
                                  '${rod.toY.toInt()} days',
                                  GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text('C${value.toInt() + 1}', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                                  );
                                },
                              ),
                            ),
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 10,
                            getDrawingHorizontalLine: (value) => FlLine(color: AppTheme.shadowDark.withOpacity(0.2), strokeWidth: 1, dashArray: [4, 4]),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: List.generate(cycleLengths.length, (i) {
                            final val = cycleLengths[i].toDouble();
                            return BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: val,
                                  width: constraints.maxWidth / (cycleLengths.length * 2),
                                  gradient: AppTheme.brandGradient,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                  backDrawRodData: BackgroundBarChartRodData(
                                    show: true,
                                    toY: 40,
                                    color: AppTheme.shadowDark.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                        swapAnimationDuration: 800.ms,
                        swapAnimationCurve: Curves.easeOutCubic,
                      );
                    }
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomStats(List<PeriodLog> logs) {
    Map<String, int> counts = {};
    for (var log in logs) {
      if (log.symptoms != null) {
        for (var sym in log.symptoms!) {
          counts[sym] = (counts[sym] ?? 0) + 1;
        }
      }
    }

    if (counts.isEmpty) {
      return NeuContainer(
        radius: 28,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('Log symptoms to see frequency.', style: GoogleFonts.inter(color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
        ),
      );
    }

    var entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    int total = counts.values.fold(0, (sum, val) => sum + val);

    return NeuContainer(
      radius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: entries.take(5).map((entry) {
          final pct = entry.value / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(entry.key, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDark, fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(color: AppTheme.shadowDark.withOpacity(0.3), borderRadius: BorderRadius.circular(4)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: pct,
                      child: Container(
                        decoration: BoxDecoration(color: AppTheme.accentPink, borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${(pct * 100).round()}%', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w700)),
              ],
            ),
          );
        }).toList(),
      ),
    );
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
    "Tracking symptoms helps identify your own unique cycle patterns."
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    final tip = _tips[dayOfYear % _tips.length];

    return NeuContainer(
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
                  Text('Daily Insight', 
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.accentPink)),
                  const SizedBox(height: 4),
                  Text(tip, 
                    style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textDark, height: 1.4, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

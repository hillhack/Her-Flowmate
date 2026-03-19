import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';
import '../widgets/cycle_phase_wheel.dart';
import '../widgets/glass_container.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pred = context.watch<PredictionService>();

    final cycleDay = pred.currentCycleDay == 0 ? 1 : pred.currentCycleDay;
    final cycleLen = pred.averageCycleLength > 0 ? pred.averageCycleLength : 28;
    final phaseName = pred.phaseDisplayName;
    final daysToNext = pred.daysUntilNextPeriod;

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Text(
                'Cycle Insights',
                style: GoogleFonts.poppins(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 32),

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

              // ── Unified Insights Surface ──────────────────────────────────
              GlassContainer(
                padding: const EdgeInsets.all(28),
                radius: 32,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cycle Length', 
                            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('$cycleLen days', 
                            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                          Text('Avg last 6 cycles', 
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Container(
                      width: 1.5,
                      height: 50,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fertile Window', 
                            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('6 days', 
                            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textDark)),
                          Text(pred.currentPhase == CyclePhase.ovulation ? 'Peak today' : 'Upcoming', 
                            style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              // Data Visualizations
              _buildSymptomFrequencyChart(),
              const SizedBox(height: 32),
              _buildHeatmap(),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomFrequencyChart() {
    return GlassContainer(
      radius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Symptom Frequency',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            'Logged over the last 3 cycles',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 10,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, meta) {
                        final style = TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, fontSize: 12);
                        String text = '';
                        switch (val.toInt()) {
                          case 0: text = 'Cramps'; break;
                          case 1: text = 'Fatigue'; break;
                          case 2: text = 'Bloat'; break;
                          case 3: text = 'Acne'; break;
                          case 4: text = 'Mood'; break;
                        }
                        return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(text, style: style));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarGroup(0, 8, AppTheme.accentPink),
                  _buildBarGroup(1, 6, AppTheme.accentPurple),
                  _buildBarGroup(2, 4, AppTheme.accentCyan),
                  _buildBarGroup(3, 3, AppTheme.neonGreen),
                  _buildBarGroup(4, 5, AppTheme.textSecondary),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1);
  }

  BarChartGroupData _buildBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: AppTheme.shadowDark.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatmap() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      radius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cramps Intensity',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textDark),
              ),
              const Icon(Icons.show_chart_rounded, color: AppTheme.accentPink),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(14, (index) {
              double intensity = 0;
              if (index > 2 && index < 7) intensity = (index == 4 || index == 5) ? 1.0 : 0.6;
              else if (index == 2 || index == 7) intensity = 0.3;

              return Container(
                width: 14,
                height: 48,
                decoration: BoxDecoration(
                  color: intensity > 0 ? AppTheme.accentPink.withOpacity(intensity) : AppTheme.shadowDark.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('2 Weeks Ago', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
              Text('Today', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1);
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

    return GlassContainer(
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

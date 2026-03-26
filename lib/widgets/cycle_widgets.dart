import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';
import 'glass_container.dart';

class CycleTimeline extends StatelessWidget {
  final int currentDay;
  final int cycleLength;
  final PredictionService pred;

  const CycleTimeline({
    super.key,
    required this.currentDay,
    required this.cycleLength,
    required this.pred,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Cycle Timeline',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Day $currentDay of $cycleLength',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: List.generate(cycleLength, (index) {
              final day = index + 1;
              final isToday = day == currentDay;

              // Mock date for color calculation
              final date = DateTime.now().add(Duration(days: day - currentDay));
              final phase = pred.getPhaseForDay(date);
              final color = AppTheme.phaseColor(phase.displayName);

              return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(2),
                    decoration: isToday
                        ? BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: color, width: 2),
                          )
                        : null,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color.withOpacity(isToday ? 1.0 : 0.4),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                  .animate(target: isToday ? 1 : 0)
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.3, 1.3),
                    duration: 1.seconds,
                    curve: Curves.easeInOut,
                  )
                  .shimmer(color: color.withOpacity(0.3));
            }),
          ),
        ),
      ],
    );
  }
}

class HormoneGraph extends StatefulWidget {
  final PredictionService pred;
  final Function(int day)? onDaySelected;

  const HormoneGraph({super.key, required this.pred, this.onDaySelected});

  @override
  State<HormoneGraph> createState() => _HormoneGraphState();
}

class _HormoneGraphState extends State<HormoneGraph> {
  int? selectedDay;

  @override
  Widget build(BuildContext context) {
    final cycleLen = widget.pred.averageCycleLength;

    return GlassContainer(
      padding: const EdgeInsets.all(24),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hormone Levels',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              if (selectedDay != null)
                Text(
                  'Day $selectedDay',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentPink,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppTheme.bgColor.withOpacity(0.9),
                    maxContentWidth: 200,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        // Only show the rich data for the first spot to avoid repetition and errors
                        if (touchedSpots.indexOf(spot) != 0) return null;

                        final day = spot.x.toInt();
                        final biology = widget.pred.getPhaseBiology(day);
                        final phase = widget.pred.getPhaseForDay(
                          DateTime.now().add(
                            Duration(days: day - widget.pred.currentCycleDay),
                          ),
                        );

                        return LineTooltipItem(
                          'Day $day: ${phase.displayName}\n',
                          const TextStyle(
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: biology['insight'],
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        );
                      }).toList();
                    },
                  ),
                  touchCallback: (event, response) {
                    if (response != null &&
                        response.lineBarSpots != null &&
                        response.lineBarSpots!.isNotEmpty) {
                      final day = response.lineBarSpots![0].x.toInt();
                      setState(() => selectedDay = day);
                      if (widget.onDaySelected != null)
                        widget.onDaySelected!(day);
                    }
                  },
                ),
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: cycleLen.toDouble(),
                minY: 0,
                maxY: 1.0,
                lineBarsData: [
                  _lineBar(
                    widget.pred,
                    'Estrogen',
                    AppTheme.hormoneColors['Estrogen']!,
                  ),
                  _lineBar(
                    widget.pred,
                    'Progesterone',
                    AppTheme.hormoneColors['Progesterone']!,
                  ),
                  _lineBar(widget.pred, 'LH', AppTheme.hormoneColors['LH']!),
                  _lineBar(widget.pred, 'FSH', AppTheme.hormoneColors['FSH']!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  LineChartBarData _lineBar(
    PredictionService pred,
    String hormone,
    Color color,
  ) {
    final List<FlSpot> spots = [];
    final cycleLen = pred.averageCycleLength;
    for (int i = 1; i <= cycleLen; i++) {
      final levels = pred.getHormoneLevels(i);
      spots.add(FlSpot(i.toDouble(), levels[hormone]!));
    }

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: AppTheme.hormoneColors.entries.map((e) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: e.value, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              e.key,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

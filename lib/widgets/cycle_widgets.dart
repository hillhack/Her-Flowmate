import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';
import 'themed_container.dart';

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
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Day $currentDay of $cycleLength',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
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

              // Optimize: Only calculate phase if it's likely to be visible or if today
              // In this simple case, we still calculate but we could memoize if it was heavier.
              final date = DateTime.now().add(Duration(days: day - currentDay));
              final phase = pred.getPhaseForDay(date);
              final color = AppTheme.phaseColor(phase.displayName);

              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(2),
                decoration:
                    isToday
                        ? BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 2),
                        )
                        : null,
                child:
                    isToday
                        ? Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(1, 1),
                              end: const Offset(1.2, 1.2),
                              duration: 1200.ms,
                              curve: Curves.easeInOut,
                            )
                            .shimmer(color: color.withValues(alpha: 0.3))
                        : Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                        ),
              );
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
  final bool showHeader;

  const HormoneGraph({
    super.key,
    required this.pred,
    this.onDaySelected,
    this.showHeader = true,
  });

  @override
  State<HormoneGraph> createState() => _HormoneGraphState();
}

class _HormoneGraphState extends State<HormoneGraph> {
  int? selectedDay;

  @override
  Widget build(BuildContext context) {
    final cycleLen = widget.pred.averageCycleLength;

    return ThemedContainer(
      type: ContainerType.glass,
      padding: const EdgeInsets.all(24),
      radius: 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showHeader) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hormone Trends',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.auto_graph_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.5),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
          if (selectedDay != null) ...[
            Row(
              children: [
                Text(
                  'Day $selectedDay',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  onPressed: () => setState(() => selectedDay = null),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor:
                        (_) => Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.9),
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
                          GoogleFonts.inter(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${biology['hormoneActivity']}\n\n${biology['energy']}',
                              style: GoogleFonts.inter(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w500,
                                fontSize: 11,
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
                      if (widget.onDaySelected != null) {
                        widget.onDaySelected!(day);
                      }
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
    final cycleLen = pred.averageCycleLength;
    final spots = List.generate(cycleLen, (i) {
      final day = i + 1;
      final levels = pred.getHormoneLevels(day);
      return FlSpot(day.toDouble(), levels[hormone]!);
    });

    return LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.3, // Slightly reduced for performance
      color: color,
      barWidth: 3, // Reduced from 4 for better rendering performance
      isStrokeCapRound: true,
      shadow: Shadow(
        color: color.withValues(alpha: 0.2),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.0)],
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
      children:
          AppTheme.hormoneColors.entries.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: e.value,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  e.key,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }).toList(),
    );
  }
}

class HormoneFocusWidget extends StatelessWidget {
  final PredictionService pred;
  final int? day;
  const HormoneFocusWidget({super.key, required this.pred, this.day});

  @override
  Widget build(BuildContext context) {
    try {
      final targetDay = day ?? pred.currentCycleDay;
      final focus = pred.getHormoneFocus(targetDay);
      final highest = focus['highest'];
      final lowest = focus['lowest'];

      if (highest == null || lowest == null) return const SizedBox.shrink();

      return ThemedContainer(
            type: ContainerType.neu,
            padding: const EdgeInsets.all(28),
            radius: 36,
            style: NeuStyle.convex,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'DAILY FOCUS',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.lightbulb_rounded,
                      color: AppTheme.accentPink.withValues(alpha: 0.4),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _focusRow(
                  context,
                  'Highest',
                  highest['name'],
                  highest['desc'],
                  AppTheme.hormoneColors[highest['name']]!,
                  Icons.trending_up_rounded,
                ),
                const SizedBox(height: 20),
                _focusRow(
                  context,
                  'Lowest',
                  lowest['name'],
                  lowest['desc'],
                  AppTheme.hormoneColors[lowest['name']] ??
                      Theme.of(context).colorScheme.primary,
                  Icons.trending_down_rounded,
                ),
              ],
            ),
          )
          .animate(key: ValueKey(targetDay))
          .fadeIn()
          .slideX(begin: 0.1, curve: Curves.easeOutCubic);
    } catch (e) {
      debugPrint('Error building HormoneFocusWidget: $e');
      return const SizedBox.shrink();
    }
  }

  Widget _focusRow(
    BuildContext context,
    String label,
    String name,
    String desc,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$label: ',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PhaseHealthTipsWidget extends StatelessWidget {
  final PredictionService pred;
  const PhaseHealthTipsWidget({super.key, required this.pred});

  @override
  Widget build(BuildContext context) {
    final phase = pred.phaseDisplayName;
    final tips = AppTheme.getPhaseHealthTips(phase);

    return ThemedContainer(
      type: ContainerType.neu,
      padding: const EdgeInsets.all(32),
      radius: 40,
      style: NeuStyle.convex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PHASE CARE',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$phase Phase Tips',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.accentPink,
                size: 28,
              ),
            ],
          ),
          const SizedBox(height: 32),
          _tipCategory(
            context,
            'Physical & Exercise',
            Icons.fitness_center_rounded,
            tips.exercise,
          ),
          const SizedBox(height: 24),
          _tipCategory(
            context,
            'Optimal Diet',
            Icons.restaurant_menu_rounded,
            tips.diet,
          ),
          const SizedBox(height: 24),
          _tipCategory(
            context,
            'Key Nutrients',
            Icons.health_and_safety_rounded,
            tips.nutrients,
          ),
        ],
      ),
    );
  }

  Widget _tipCategory(
    BuildContext context,
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppTheme.accentPink),
            const SizedBox(width: 10),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              items
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPink.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentPink.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        item,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

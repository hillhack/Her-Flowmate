import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';
import '../widgets/neu_container.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pred = context.watch<PredictionService>();
    final cycleLen = pred.averageCycleLength > 0 ? pred.averageCycleLength : 28;
    final currentDay = pred.currentCycleDay;

    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      appBar: AppBar(
        backgroundColor: AppTheme.frameColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const NeuContainer(
              radius: 12,
              padding: EdgeInsets.zero,
              child: Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
            ),
          ),
        ),
        title: Text(
          'Cycle Timeline',
          style: GoogleFonts.poppins(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLegendItem(
                      'Period',
                      AppTheme.phaseColors['Menstrual']!,
                    ),
                    _buildLegendItem(
                      'Follicular',
                      AppTheme.phaseColors['Follicular']!,
                    ),
                    _buildLegendItem(
                      'Ovulation',
                      AppTheme.phaseColors['Ovulation']!,
                    ),
                    _buildLegendItem('Luteal', AppTheme.phaseColors['Luteal']!),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                  physics: const BouncingScrollPhysics(),
                  itemCount: cycleLen,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isToday = day == currentDay;
                    final phase = _getPhaseForDay(day, cycleLen);
                    final phaseColor = AppTheme.phaseColor(phase);

                    return _TimelineRow(
                          day: day,
                          isToday: isToday,
                          phaseName: phase,
                          phaseColor: phaseColor,
                        )
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: 30 * index))
                        .slideX(begin: 0.05);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _getPhaseForDay(int day, int cycleLen) {
    if (day <= 5) return 'Menstrual';
    final lutealPhaseLength = 14;
    final ovulationDay = cycleLen - lutealPhaseLength;
    if (day < ovulationDay - 5) return 'Follicular';
    if (day >= ovulationDay - 5 && day <= ovulationDay) return 'Ovulation';
    return 'Luteal';
  }
}

class _TimelineRow extends StatelessWidget {
  final int day;
  final bool isToday;
  final String phaseName;
  final Color phaseColor;

  const _TimelineRow({
    required this.day,
    required this.isToday,
    required this.phaseName,
    required this.phaseColor,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          // Day column
          SizedBox(
            width: 32,
            child: Text(
              '$day',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                color: isToday ? AppTheme.accentPink : AppTheme.textSecondary,
              ),
            ),
          ),

          // Marker
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: isToday ? phaseColor : AppTheme.frameColor,
                  border: Border.all(color: phaseColor, width: 2),
                  shape: BoxShape.circle,
                  boxShadow:
                      isToday
                          ? [
                            BoxShadow(
                              color: phaseColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ]
                          : null,
                ),
                child:
                    isToday
                        ? const Icon(
                          Icons.star_rounded,
                          size: 10,
                          color: Colors.white,
                        )
                        : null,
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: phaseColor.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),

          const SizedBox(width: 20),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child:
                  isToday
                      ? NeuContainer(
                        radius: 20,
                        onTap: () {},
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: _rowContent(),
                      )
                      : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: phaseColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: _rowContent(),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowContent() {
    return Row(
      children: [
        Text(
          isToday ? 'Today' : 'Cycle Day $day',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isToday ? FontWeight.w800 : FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const Spacer(),
        Text(
          phaseName,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: phaseColor,
          ),
        ),
      ],
    );
  }
}

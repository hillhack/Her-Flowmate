import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../utils/app_theme.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pred = context.watch<PredictionService>();
    final cycleLen = pred.averageCycleLength;
    final currentDay = pred.currentCycleDay;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: AppTheme.neuDecoration(radius: 12, color: AppTheme.frameColor),
              child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textDark),
            ),
          ),
        ),
        title: Text(
          'Cycle Timeline',
          style: GoogleFonts.poppins(color: AppTheme.textDark, fontWeight: FontWeight.w700),
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
                    _buildLegendItem('Period', AppTheme.accentPink),
                    _buildLegendItem('Follicular', AppTheme.phaseColors['Follicular']!),
                    _buildLegendItem('Ovulation', AppTheme.phaseColors['Ovulation']!),
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
                    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideX(begin: 0.05);
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
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textDark.withOpacity(0.6), fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _getPhaseForDay(int day, int cycleLen) {
    // Simple mock logic for timeline phases
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
    required this.day, required this.isToday, 
    required this.phaseName, required this.phaseColor
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Day column
            SizedBox(
              width: 30,
              child: Text(
                '$day',
                style: GoogleFonts.poppins(
                  fontSize: 14, 
                  fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                  color: isToday ? AppTheme.accentPink : AppTheme.textDark.withOpacity(0.3),
                ),
              ),
            ),
            
            // Marker
            Column(
              children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    color: isToday ? phaseColor : Colors.transparent,
                    border: Border.all(color: phaseColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: isToday ? const Icon(Icons.person_rounded, size: 8, color: Colors.white) : null,
                ),
                Expanded(
                  child: Container(width: 2, color: phaseColor.withOpacity(0.2)),
                ),
              ],
            ),
            
            const SizedBox(width: 20),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: isToday 
                    ? AppTheme.neuDecoration(radius: 16, color: AppTheme.frameColor)
                    : BoxDecoration(
                        color: phaseColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                  child: Row(
                    children: [
                      Text(
                        isToday ? 'Today' : 'Cycle Day $day',
                        style: GoogleFonts.inter(
                          fontSize: 14, 
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                          color: isToday ? AppTheme.textDark : AppTheme.textDark.withOpacity(0.5)
                        ),
                      ),
                      const Spacer(),
                      Text(
                        phaseName,
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: phaseColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

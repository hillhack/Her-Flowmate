import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/prediction_service.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';
import '../widgets/common/app_back_button.dart';


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
        leading: Semantics(
          label: 'Back',
          button: true,
          child: const Padding(
            padding: EdgeInsets.all(4.0),
            child: AppBackButton(),
          ),
        ),
        title: Text(
          'Cycle Timeline',
          style: GoogleFonts.poppins(
            color: Theme.of(context).colorScheme.onSurface,
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
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildLegendItem('Menstrual', AppTheme.phaseColors['Menstrual']!),
                    const SizedBox(width: 16),
                    _buildLegendItem('Follicular', AppTheme.phaseColors['Follicular']!),
                    const SizedBox(width: 16),
                    _buildLegendItem('Ovulation', AppTheme.phaseColors['Ovulation']!),
                    const SizedBox(width: 16),
                    _buildLegendItem('Luteal', AppTheme.phaseColors['Luteal']!),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: cycleLen <= 0 ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'Log at least one period to see your timeline.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ) : RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  onRefresh: () async {
                    if (context.mounted) {
                      await context.read<StorageService>().syncUserWithBackend();
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: cycleLen,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final isToday = day == currentDay;
                      final targetDate = DateTime.now().add(Duration(days: day - currentDay));
                      final phaseEnum = pred.getPhaseForDay(targetDate);
                      final phaseName = phaseEnum.name.substring(0, 1).toUpperCase() + phaseEnum.name.substring(1);
                      final phaseColor = AppTheme.phaseColor(phaseName);

                      Widget rowWidget = _TimelineRow(
                        day: day,
                        isToday: isToday,
                        isLast: index == cycleLen - 1,
                        phaseName: phaseName,
                        phaseColor: phaseColor,
                      );

                      if (index < 5) {
                        rowWidget = rowWidget.animate()
                            .fadeIn(delay: Duration(milliseconds: 30 * index))
                            .slideX(begin: 0.05);
                      }
                      
                      return rowWidget;
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Semantics(
      label: '$label phase indicator',
      button: false,
      child: Column(
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
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isLast;
  final String phaseName;
  final Color phaseColor;

  const _TimelineRow({
    required this.day,
    required this.isToday,
    required this.isLast,
    required this.phaseName,
    required this.phaseColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Cycle day $day, $phaseName phase, ${isToday ? "today" : ""}',
      button: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day column
          SizedBox(
            width: 40,
            child: Padding(
              padding: const EdgeInsets.only(top: 14.0, right: 4.0),
              child: Text(
                '$day',
                textAlign: TextAlign.right,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                  color: isToday ? AppTheme.accentPink : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Marker
          Semantics(
            excludeSemantics: true,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isToday ? phaseColor : AppTheme.frameColor,
                    border: Border.all(color: phaseColor, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: isToday
                      ? const Icon(Icons.star_rounded, size: 10, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 48,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 20),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: phaseColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: isToday ? Border.all(color: phaseColor.withValues(alpha: 0.6), width: 1.5) : null,
                ),
                child: _rowContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rowContent(BuildContext context) {
    final contrastColor = HSLColor.fromColor(phaseColor).withLightness(0.4).toColor();

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
            color: context.watch<StorageService>().isDarkMode ? phaseColor : contrastColor,
          ),
        ),
      ],
    );
  }
}

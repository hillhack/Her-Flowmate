import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/prediction_service.dart';

class ConceptionWheel extends StatelessWidget {
  final PredictionService pred;
  final double size;

  const ConceptionWheel({super.key, required this.pred, this.size = 260});

  @override
  Widget build(BuildContext context) {
    final currentDay = pred.currentCycleDay == 0 ? 1 : pred.currentCycleDay;
    final cycleLen = pred.averageCycleLength;
    final todayChance = pred.currentConceptionChance;

    String statusStr = 'Low Chance';
    Color statusColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.6);
    IconData statusIcon = Icons.calendar_today_rounded;

    if (todayChance >= 25) {
      statusStr = 'Peak Fertility';
      statusColor = Theme.of(context).colorScheme.primary;
      statusIcon = Icons.favorite_rounded;
    } else if (todayChance >= 10) {
      statusStr = 'High Chance';
      statusColor = Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.8);
      statusIcon = Icons.stars_rounded;
    } else if (todayChance >= 5) {
      statusStr = 'Moderate';
      statusColor = Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.5);
      statusIcon = Icons.water_drop_rounded;
    }

    return SizedBox(
      width: size + 40,
      height: size + 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Wheel
          CustomPaint(
            size: Size(size, size),
            painter: _ConceptionWheelPainter(
              pred: pred,
              currentDay: currentDay,
              cycleLength: cycleLen,
              primaryColor: Theme.of(context).colorScheme.primary,
              baseColor: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          // Center Info
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Day $currentDay / $cycleLen',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                statusStr,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Icon(statusIcon, color: statusColor, size: 24),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConceptionWheelPainter extends CustomPainter {
  final PredictionService pred;
  final int currentDay;
  final int cycleLength;
  final Color primaryColor;
  final Color baseColor;

  _ConceptionWheelPainter({
    required this.pred,
    required this.currentDay,
    required this.cycleLength,
    required this.primaryColor,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cycleLength <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Gap between segments
    final gapAngle = 0.04;
    final totalGapAngle = gapAngle * cycleLength;
    final sweepPerDay = (2 * pi - totalGapAngle) / cycleLength;

    // Start drawing from top
    final startAngleOffset = -pi / 2;

    final today = DateTime.now();
    // Assuming cycle day starts at 1, periodStart is relative to today
    final periodStart = today.subtract(Duration(days: currentDay - 1));

    final strokeW = 18.0;

    for (int i = 0; i < cycleLength; i++) {
      final dayAngle = startAngleOffset + (i * (sweepPerDay + gapAngle));
      final dateForDay = periodStart.add(Duration(days: i));

      final chance = pred.getConceptionChance(dateForDay);

      Color segmentColor;
      if (chance >= 25) {
        segmentColor = primaryColor; // Peak
      } else if (chance >= 10) {
        segmentColor = primaryColor.withValues(alpha: 0.6); // High
      } else if (chance >= 5) {
        segmentColor = primaryColor.withValues(alpha: 0.3); // Moderate
      } else {
        segmentColor = baseColor.withValues(alpha: 0.08); // Low
      }

      final paint =
          Paint()
            ..color = segmentColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeW
            ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        dayAngle,
        sweepPerDay,
        false,
        paint,
      );

      // Draw "Today" Marker
      if (i == currentDay - 1) {
        final markerPaint =
            Paint()
              ..color = baseColor.withValues(alpha: 0.8)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius + 16),
          dayAngle - 0.02,
          sweepPerDay + 0.04,
          false,
          markerPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConceptionWheelPainter oldDelegate) {
    return oldDelegate.currentDay != currentDay ||
        oldDelegate.cycleLength != cycleLength ||
        oldDelegate.primaryColor != primaryColor;
  }
}

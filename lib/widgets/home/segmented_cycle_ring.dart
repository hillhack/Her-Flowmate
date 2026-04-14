import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_theme.dart';
import '../../models/cycle_engine.dart';
import '../../models/period_log.dart';

class SegmentedCycleRing extends StatelessWidget {
  final int currentDay;
  final int cycleLength;
  final List<dynamic> logs; // Needed to calculate phases for each day
  final double size;

  const SegmentedCycleRing({
    super.key,
    required this.currentDay,
    required this.cycleLength,
    required this.logs,
    this.size = 280,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          _RingGlow(size: size),

          // The Actual Ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              currentDay: currentDay,
              cycleLength: cycleLength,
              logs: logs,
              isDark: Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final int currentDay;
  final int cycleLength;
  final List<dynamic> logs;
  final bool isDark;

  _RingPainter({
    required this.currentDay,
    required this.cycleLength,
    required this.logs,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2; // Restore original large size
    final innerRadius = outerRadius - 28; // Original thickness
    final labelRadius = outerRadius + 24; // Labels outside the ring
    final segmentGap = 0.04;

    final double sweepAngle = (2 * math.pi) / cycleLength;
    const double startAngleOffset = -math.pi / 2;

    final today = DateTime.now();
    final currentCycleStart = today.subtract(Duration(days: currentDay - 1));

    // Phase storage for labels
    Map<CyclePhase, List<int>> phaseSegments = {};

    for (int i = 0; i < cycleLength; i++) {
      final dayNum = i + 1;
      final isCurrent = dayNum == currentDay;
      
      final segmentDate = currentCycleStart.add(Duration(days: i));
      final phase = CycleEngine.getPhaseForDate(segmentDate, logs.cast<PeriodLog>(), cycleLength);
      final color = AppTheme.getPhaseColor(phase);

      // Track segments for labels
      if (!phaseSegments.containsKey(phase)) phaseSegments[phase] = [];
      phaseSegments[phase]!.add(i);

      final double startAngle = startAngleOffset + (i * sweepAngle);
      final double actualSweep = sweepAngle - segmentGap;

      // Special Ovulation Highlighting
      if (phase == CyclePhase.ovulation) {
        final ovColor = color;
        final ovPaint = Paint()
          ..color = ovColor.withValues(alpha: 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: outerRadius + 6),
          startAngle,
          actualSweep,
          true,
          ovPaint,
        );
      }

      // Draw Segment
      final paint = Paint()
        ..color = isCurrent ? color : color.withValues(alpha: isDark ? 0.3 : 0.4)
        ..style = PaintingStyle.fill;

      if (isCurrent) {
        final highlightPaint = Paint()
          ..color = color.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: outerRadius + 4),
          startAngle,
          actualSweep,
          true,
          highlightPaint,
        );
      }

      final path = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: outerRadius),
          startAngle,
          actualSweep,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: innerRadius),
          startAngle + actualSweep,
          -actualSweep,
          false,
        )
        ..close();

      canvas.drawPath(path, paint);

      // Draw Day Number
      if (cycleLength <= 35) {
        final textAngle = startAngle + (actualSweep / 2);
        final textRadius = (outerRadius + innerRadius) / 2;
        final textOffset = Offset(
          center.dx + textRadius * math.cos(textAngle),
          center.dy + textRadius * math.sin(textAngle),
        );

        final textPainter = TextPainter(
          text: TextSpan(
            text: '$dayNum',
            style: GoogleFonts.inter(
              fontSize: isCurrent ? 11 : 9,
              fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
              color: isCurrent
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppTheme.textSecondary),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          textOffset - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }

    // Draw Phase Labels
    phaseSegments.forEach((phase, indices) {
      if (indices.isEmpty) return;

      // Find the midpoint of the phase block
      // Note: This logic assumes contiguous segments, which is true for cycle phases
      final midIndex = indices[indices.length ~/ 2];
      final labelAngle = startAngleOffset + (midIndex * sweepAngle) + (sweepAngle / 2);
      
      final labelOffset = Offset(
        center.dx + labelRadius * math.cos(labelAngle),
        center.dy + labelRadius * math.sin(labelAngle),
      );

      final labelName = phase.displayName;
      final labelColor = AppTheme.getPhaseColor(phase);

      final textPainter = TextPainter(
        text: TextSpan(
          text: labelName.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: labelColor.withValues(alpha: isDark ? 0.8 : 0.7),
            letterSpacing: 1.0,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Save canvas state to rotate text
      canvas.save();
      canvas.translate(labelOffset.dx, labelOffset.dy);
      
      // Rotate text to follow circle
      // Adjust rotation so text is readable (not upside down)
      double rotation = labelAngle + (math.pi / 2);
      if (labelAngle > 0 && labelAngle < math.pi) {
         // Optionally flip text if it's at the bottom for better readability
         // but for labels outside, it usually looks better facing outwards or inwards consistently
      }
      
      canvas.rotate(rotation);
      textPainter.paint(
        canvas,
        Offset(-textPainter.width / 2, -textPainter.height / 2),
      );
      canvas.restore();
    });
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => 
      oldDelegate.currentDay != currentDay || oldDelegate.cycleLength != cycleLength;
}

class _RingGlow extends StatelessWidget {
  final double size;
  const _RingGlow({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 1.2,
      height: size * 1.2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppTheme.roseCoralPrimary.withValues(alpha: context.isDarkMode ? 0.15 : 0.1),
            AppTheme.roseCoralPrimary.withValues(alpha: 0.0),
          ],
          stops: const [0.4, 1.0],
        ),
      ),
    );
  }
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'glass_container.dart';

class CyclePhaseWheel extends StatelessWidget {
  final int currentCycleDay;
  final int cycleLength;
  final String currentPhase;
  final int daysUntilNextPeriod;

  const CyclePhaseWheel({
    super.key,
    required this.currentCycleDay,
    required this.cycleLength,
    required this.currentPhase,
    required this.daysUntilNextPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        cycleLength > 0 ? currentCycleDay / cycleLength.clamp(1, 999) : 0.0;
    final accentColor = AppTheme.phaseColor(currentPhase);

    return RepaintBoundary(
      child: GlassContainer(
        width: 300,
        height: 300,
        radius: 150,
        blur: 20,
        opacity: 0.1,
        borderColor: accentColor.withValues(alpha: 0.2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Inner decorative ring
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 2,
                ),
              ),
            ),

            // Progress arc
            CustomPaint(
              size: const Size(260, 260),
              painter: _ArcPainter(progress: progress, color: accentColor),
            ),

            // Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currentPhase,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Day $currentCycleDay / $cycleLength",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  daysUntilNextPeriod >= 0
                      ? "Next in $daysUntilNextPeriod d"
                      : "Late by ${daysUntilNextPeriod.abs()} d",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ArcPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        size.width / 2 - 13.0; // Align with the center of the 260px ring

    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round
          ..color = color;

    // Background track for the arc? No, keep it clean Neumorphic.

    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.progress != progress || old.color != color;
}

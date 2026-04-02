import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'themed_container.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress =
        cycleLength > 0 ? currentCycleDay / cycleLength.clamp(1, 999) : 0.0;
    final accentColor = colorScheme.phaseColor(currentPhase);
    final textColor = colorScheme.onSurface;
    final secondaryTextColor = textColor.withValues(alpha: 0.7);

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSize = min(constraints.maxWidth * 0.9, 300.0);
        final innerSize = maxSize * 0.82; // Adjusted ratio for better spacing

        return Semantics(
          label:
              'Cycle phase: $currentPhase, day $currentCycleDay of $cycleLength, $daysUntilNextPeriod days until next period',
          child: RepaintBoundary(
            child: ThemedContainer(
              type: ContainerType.glass,
              width: maxSize,
              height: maxSize,
              radius: maxSize / 2,
              blur: kIsWeb ? 0 : 20,
              opacity: 0.1,
              borderColor: accentColor.withValues(alpha: 0.2),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inner decorative ring
                  Container(
                    width: innerSize,
                    height: innerSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Progress arc
                  CustomPaint(
                    size: Size(innerSize, innerSize),
                    painter: _ArcPainter(
                      progress: progress,
                      color: accentColor,
                      strokeWidth: 12,
                    ),
                  ),
                  // Content
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentPhase,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w800,
                          fontSize: maxSize * 0.08, // Dynamic font size
                        ),
                      ),
                      SizedBox(height: maxSize * 0.02),
                      Text(
                        "Day $currentCycleDay / $cycleLength",
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: maxSize * 0.05,
                        ),
                      ),
                      SizedBox(height: maxSize * 0.01),
                      Text(
                        daysUntilNextPeriod >= 0
                            ? "Next in $daysUntilNextPeriod d"
                            : "Late by ${daysUntilNextPeriod.abs()} d",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                          fontSize: maxSize * 0.045,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  const _ArcPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Align the stroke inside the radius to stay within the bounds of innerSize
    final radius = (size.width / 2) - (strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..color = color;

    canvas.drawArc(rect, -pi / 2, 2 * pi * progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}

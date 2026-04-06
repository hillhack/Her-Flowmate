import 'dart:math' as math;
import 'package:flutter/material.dart';

class EvolutionWheel extends StatelessWidget {
  final double progress;
  final Color activeColor;
  final double size;

  const EvolutionWheel({
    super.key,
    required this.progress,
    required this.activeColor,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WheelPainter(
        progress: progress.clamp(0.0, 1.0),
        activeColor: activeColor,
        trackColor: Theme.of(
          context,
        ).colorScheme.onSurface.withValues(alpha: 0.08),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  _WheelPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 10;
    const strokeWidth = 14.0;

    // 1. Draw Track
    final trackPaint =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) return;

    // 2. Draw Glow Layer (Subtle)
    final glowPaint =
        Paint()
          ..color = activeColor.withValues(alpha: 0.2)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 8
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final sweepAngle = 2 * math.pi * progress;
    const startAngle = -math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );

    // 3. Draw Active Progress with Gradient
    final activePaint =
        Paint()
          ..shader = SweepGradient(
            colors: [
              activeColor.withValues(alpha: 0.6),
              activeColor,
              activeColor,
            ],
            stops: const [0.0, 0.5, 1.0],
            transform: const GradientRotation(startAngle),
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor;
  }
}

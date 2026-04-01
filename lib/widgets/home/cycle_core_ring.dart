import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/prediction_service.dart';
import '../../utils/app_theme.dart';
import '../glass_container.dart';
import '../info_widgets.dart';
import 'package:intl/intl.dart';

class CycleCoreRing extends StatelessWidget {
  final PredictionService pred;

  const CycleCoreRing({super.key, required this.pred});

  @override
  Widget build(BuildContext context) {
    final phaseName = pred.phaseDisplayName;
    final day = pred.currentCycleDay == 0 ? 1 : pred.currentCycleDay;
    final cycleLen = pred.averageCycleLength;
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing based on screen width
    final ringSize = (screenWidth * 0.55).clamp(160.0, 240.0);
    final innerSize = ringSize * 0.77; // ~170/220 ratio
    final glowSize = ringSize * 0.64; // ~140/220 ratio
    final outerRing = ringSize * 0.95; // ~210/220 ratio

    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft Glow Effect
          Container(
            width: glowSize,
            height: glowSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.phaseColor(phaseName).withValues(alpha: 0.25),
                  blurRadius: ringSize * 0.18,
                  spreadRadius: ringSize * 0.04,
                ),
              ],
            ),
          ),
          SizedBox(
            width: outerRing,
            height: outerRing,
            child: CustomPaint(
              painter: _CycleRingPainter(
                progress: day / (cycleLen == 0 ? 28 : cycleLen),
                activeColor: AppTheme.phaseColor(phaseName),
                trackColor: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          GlassContainer(
            onTap: () {
              final biology = pred.getPhaseBiology(day);
              final phase = pred.phaseDisplayName;
              final symptoms = AppTheme.getPhaseSymptoms(phase);

              showGlassInfoPopup(
                context,
                title: '$phase Phase',
                explanation:
                    '${biology['hormoneActivity']}\n\n${biology['energy']}\n\n${biology['mood']}',
                tip: 'Common symptoms: ${symptoms.join(", ")}',
              );
            },
            width: innerSize,
            height: innerSize,
            radius: innerSize / 2,
            borderColor: Colors.white.withValues(alpha: 0.5),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    phaseName.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: (ringSize * 0.08).clamp(14.0, 18.0),
                      fontWeight: FontWeight.w900,
                      color: AppTheme.getPhaseColor(pred.currentPhase),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_rounded,
                        size: 12,
                        color: AppTheme.accentPink,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${pred.currentConceptionChance}% Chance',
                        style: GoogleFonts.inter(
                          fontSize: (ringSize * 0.05).clamp(10.0, 12.0),
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMiniInfo(
                    label: 'NEXT PERIOD',
                    value:
                        pred.nextPeriodDate != null
                            ? DateFormat('MMM d').format(pred.nextPeriodDate!)
                            : '--',
                  ),
                  const SizedBox(height: 6),
                  _buildMiniInfo(
                    label: 'OVULATION',
                    value:
                        pred.daysUntilOvulation == 0
                            ? 'Today'
                            : (pred.daysUntilOvulation > 0
                                ? 'in ${pred.daysUntilOvulation}d'
                                : '--'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniInfo({required String label, required String value}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSecondary.withAlpha(180),
            letterSpacing: 0.8,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
      ],
    );
  }
}

class _CycleRingPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color trackColor;

  _CycleRingPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // 1. Draw Track
    final trackPaint =
        Paint()
          ..color = trackColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12
          ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0) {
      return;
    }

    // 2. Prepare Gradient & Paint for Active Arc
    final sweepAngle = 2 * 3.14159265359 * progress;

    // Outer Glow (More Vibrant)
    final shadowPaint =
        Paint()
          ..color = activeColor.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265359 / 2,
      sweepAngle,
      false,
      shadowPaint,
    );

    final activePaint =
        Paint()
          ..shader = SweepGradient(
            colors: [
              activeColor.withValues(alpha: 0.4),
              activeColor,
              activeColor,
            ],
            stops: const [0.0, 0.5, 1.0],
            transform: const GradientRotation(-3.14159265359 / 2),
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 16
          ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159265359 / 2, // Start at top
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CycleRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.activeColor != activeColor;
  }
}

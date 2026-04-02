import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class BrandName extends StatelessWidget {
  final double fontSize;

  const BrandName({super.key, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          // "Her" - Bold & Vibrant Cursive
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
            child: Text(
              'Her ',
              style: GoogleFonts.dancingScript(
                fontSize: fontSize * 1.35,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2, // Improved line-height
                shadows: [
                  Shadow(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
          ),

          // "FlowMate" - Modern High-Contrast
          ShaderMask(
            shaderCallback:
                (bounds) => LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.secondary,
                    colorScheme.tertiaryContainer.withValues(alpha: 0.8) ==
                            Colors.transparent
                        ? colorScheme.primary
                        : colorScheme.tertiary,
                  ],
                ).createShader(
                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                ),
            child: Text(
              'FlowMate',
              style: AppTheme.playfair(
                fontSize: fontSize * 0.95,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ).copyWith(
                letterSpacing: 0.5,
                height: 1.2, // Improved line-height
                shadows: [
                  Shadow(
                    color: colorScheme.tertiary.withValues(alpha: 0.5),
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().shimmer(duration: 2.seconds, color: Colors.white24);
  }
}

class BrandLogo extends StatelessWidget {
  final double size;
  final bool showName;
  final double nameFontSize;
  final String? imagePath;

  const BrandLogo({
    super.key,
    this.size = 80,
    this.showName = false,
    this.nameFontSize = 32,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Bottom Glow Layer
              Animate(
                onPlay: (c) => c.repeat(reverse: true),
                effects: const [
                  ScaleEffect(
                    begin: Offset(0.8, 0.8),
                    end: Offset(1.2, 1.2),
                    duration: Duration(seconds: 2),
                    curve: Curves.easeInOut,
                  ),
                ],
                child: Container(
                  width: size * 0.8,
                  height: size * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues(alpha: 0.35),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),

              // Main Logo Mark
              imagePath != null
                  ? Image.asset(
                    imagePath!,
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                    frameBuilder: (
                      context,
                      child,
                      frame,
                      wasSynchronouslyLoaded,
                    ) {
                      if (wasSynchronouslyLoaded || frame != null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint('Error loading logo: $error');
                      return _BrandIconMark(size: size);
                    },
                  )
                  : _BrandIconMark(size: size),
            ],
          ),
        ),
        if (showName) ...[
          const SizedBox(height: 16),
          BrandName(fontSize: nameFontSize),
        ],
      ],
    );
  }
}

class _BrandIconMark extends StatelessWidget {
  final double size;
  const _BrandIconMark({required this.size});

  @override
  Widget build(BuildContext context) {
    return Animate(
      onPlay: (c) => c.repeat(reverse: true),
      effects: const [
        ScaleEffect(
          begin: Offset(1, 1),
          end: Offset(1.08, 1.08),
          duration: Duration(milliseconds: 2000),
          curve: Curves.easeInOutSine,
        ),
      ],
      child: CustomPaint(
        size: Size(size, size),
        painter: _LogoPainter(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  final LinearGradient gradient;
  _LogoPainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = gradient.createShader(
            Rect.fromLTWH(0, 0, size.width, size.height),
          )
          ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // A fluid 'H' / drop / flow shape
    // Left stem (droplet-like)
    path.moveTo(w * 0.3, h * 0.2);
    path.quadraticBezierTo(w * 0.1, h * 0.5, w * 0.3, h * 0.9);
    path.lineTo(w * 0.45, h * 0.9);
    path.quadraticBezierTo(w * 0.3, h * 0.5, w * 0.45, h * 0.1);
    path.close();

    // Right stem (droplet-like reverse)
    path.moveTo(w * 0.7, h * 0.1);
    path.quadraticBezierTo(w * 0.9, h * 0.5, w * 0.7, h * 0.9);
    path.lineTo(w * 0.55, h * 0.9);
    path.quadraticBezierTo(w * 0.7, h * 0.5, w * 0.55, h * 0.2);
    path.close();

    // Bridge / Flow line
    path.moveTo(w * 0.35, h * 0.45);
    path.quadraticBezierTo(w * 0.5, h * 0.55, w * 0.65, h * 0.45);
    path.lineTo(w * 0.65, h * 0.55);
    path.quadraticBezierTo(w * 0.5, h * 0.65, w * 0.35, h * 0.55);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class NeonButterfly extends StatefulWidget {
  final double size;
  final Color? color;
  final bool animateOnTap;

  const NeonButterfly({
    super.key,
    this.size = 24,
    this.color,
    this.animateOnTap = false,
  });

  @override
  State<NeonButterfly> createState() => NeonButterflyState();
}

class NeonButterflyState extends State<NeonButterfly> {
  bool _isTapped = false;

  void triggerTapAnimation() {
    if (widget.animateOnTap) {
      setState(() => _isTapped = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reduceMotion =
        MediaQuery.of(context).accessibleNavigation ||
        MediaQuery.of(context).disableAnimations;

    if (_isTapped) {
      return Animate(
        target: reduceMotion ? 1 : null, // Snap to end if reduced motion
        effects: [
          ScaleEffect(
            begin: const Offset(1, 1),
            end: const Offset(1.5, 1.5),
            duration: 400.ms,
          ),
          MoveEffect(
            begin: Offset.zero,
            end: const Offset(0, -100),
            duration: 800.ms,
            curve: Curves.easeOutCubic,
          ),
          FadeEffect(begin: 1.0, end: 0.0, duration: 800.ms),
        ],
        child: RepaintBoundary(
          child: _buildButterflyBody(context, isGlowing: true),
        ),
      );
    }

    return Animate(
      onPlay: (c) => c.repeat(),
      target: reduceMotion ? 0 : null,
      effects: [
        // Smooth floating path around the button
        const MoveEffect(
          begin: Offset(-5, -5),
          end: Offset(5, 5),
          duration: Duration(seconds: 3),
          curve: Curves.easeInOutSine,
        ),
      ],
      child: Animate(
        onPlay: (c) => c.repeat(reverse: true),
        target: reduceMotion ? 0 : null,
        effects: [
          // Wing flapping effect
          const ScaleEffect(
            begin: Offset(1, 1),
            end: Offset(0.3, 1),
            duration: Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          ),
          // Glow Pulse
          ShimmerEffect(
            duration: const Duration(seconds: 3),
            color: colorScheme.primaryContainer.withValues(alpha: 0.6),
          ),
        ],
        child: Semantics(
          label: 'Butterfly decoration',
          excludeSemantics: true,
          child: RepaintBoundary(child: _buildButterflyBody(context)),
        ),
      ),
    );
  }

  Widget _buildButterflyBody(BuildContext context, {bool isGlowing = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _ButterflyPainter(
        color: widget.color ?? colorScheme.primary,
        secondaryColor: colorScheme.tertiary,
        isGlowing: isGlowing,
      ),
    );
  }
}

class _ButterflyPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;
  final bool isGlowing;

  _ButterflyPainter({
    required this.color,
    required this.secondaryColor,
    this.isGlowing = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [color, secondaryColor],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
          ..style = PaintingStyle.fill;

    // Enhanced neon glow
    final glowPower = isGlowing ? 2.0 : 1.0;
    final shadowPaint1 =
        Paint()
          ..color = color.withValues(alpha: 0.5 * glowPower)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8 * glowPower);
    final shadowPaint2 =
        Paint()
          ..color = secondaryColor.withValues(alpha: 0.3 * glowPower)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 16 * glowPower);

    final path = Path();
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    void drawWing(double factorX, double factorY) {
      path.moveTo(cx, cy);
      path.cubicTo(
        cx + (w * 0.45 * factorX),
        cy - (h * 0.6 * factorY),
        cx + (w * 0.6 * factorX),
        cy + (h * 0.2 * factorY),
        cx,
        cy,
      );
      path.moveTo(cx, cy);
      path.cubicTo(
        cx + (w * 0.35 * factorX),
        cy + (h * 0.5 * factorY),
        cx + (w * 0.15 * factorX),
        cy + (h * 0.6 * factorY),
        cx,
        cy,
      );
    }

    drawWing(-1, 1);
    drawWing(1, 1);

    canvas.drawPath(path, shadowPaint2);
    canvas.drawPath(path, shadowPaint1);
    canvas.drawPath(path, paint);

    // Subtle wing pattern
    final detailPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;
    canvas.drawPath(path, detailPaint);

    // Tapered body
    final bodyPaint = Paint()..color = Colors.white;
    final bodyPath =
        Path()
          ..moveTo(cx, cy - h * 0.35)
          ..quadraticBezierTo(cx + w * 0.06, cy, cx, cy + h * 0.35)
          ..quadraticBezierTo(cx - w * 0.06, cy, cx, cy - h * 0.35);
    canvas.drawPath(bodyPath, bodyPaint);
  }

  @override
  bool shouldRepaint(covariant _ButterflyPainter oldDelegate) =>
      oldDelegate.isGlowing != isGlowing ||
      oldDelegate.color != color ||
      oldDelegate.secondaryColor != secondaryColor;
}

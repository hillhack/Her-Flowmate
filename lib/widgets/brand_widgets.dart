import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';

class BrandName extends StatelessWidget {
  final double fontSize;

  const BrandName({super.key, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // "Her" - Bold & Vibrant Cursive
            ShaderMask(
              shaderCallback:
                  (bounds) => const LinearGradient(
                    colors: [
                      Color(0xFFFF1493),
                      Color(0xFFFF69B4),
                    ], // Magenta to Hot Pink
                  ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
              child: Text(
                'Her ',
                style: GoogleFonts.dancingScript(
                  fontSize: fontSize * 1.35,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFFF1493).withValues(alpha: 0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
            ),

            // "FlowMate" - Modern High-Contrast
            ShaderMask(
              shaderCallback:
                  (bounds) => const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFF69B4),
                      Color(0xFF9370DB),
                    ], // Pink to Radiant Purple
                  ).createShader(
                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                  ),
              child: Text(
                'FlowMate',
                style: GoogleFonts.quicksand(
                  fontSize: fontSize * 0.95,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF9370DB).withValues(alpha: 0.5),
                      blurRadius: 15,
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 2.seconds, color: Colors.white24);
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
                    color: AppTheme.accentPink.withValues(alpha: 0.35),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentPink.withValues(alpha: 0.2),
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
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.accentPink,
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
        painter: _LogoPainter(gradient: AppTheme.brandGradient),
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
    if (_isTapped) {
      return Animate(
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
        child: _buildButterflyBody(isGlowing: true),
      );
    }

    return Animate(
      onPlay: (c) => c.repeat(),
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
            color: const Color(
              0xFFFADADD,
            ).withValues(alpha: 0.6), // Light Pink Glow
          ),
        ],
        child: _buildButterflyBody(),
      ),
    );
  }

  Widget _buildButterflyBody({bool isGlowing = false}) {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: _ButterflyPainter(
        color: widget.color ?? const Color(0xFFFF7FA5), // Soft Pink
        secondaryColor: const Color(0xFFE6A8FF), // Lavender
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

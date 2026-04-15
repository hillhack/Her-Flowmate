import 'dart:math';
import 'package:flutter/material.dart';

class PansyAnimationOverlay extends StatefulWidget {
  const PansyAnimationOverlay({super.key});

  @override
  State<PansyAnimationOverlay> createState() => _PansyAnimationOverlayState();
}

class _PansyAnimationOverlayState extends State<PansyAnimationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int numFlowers = 150;
  final List<PansyParticle> particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..addListener(() {
      if (mounted) setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < numFlowers; i++) {
        particles.add(
          PansyParticle(
            startOffset: Offset(size.width / 2, size.height * 0.8),
            screenSize: size,
            random: _random,
          ),
        );
      }
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: PansyPainter(
            particles: particles,
            progress: _controller.value,
          ),
        ),
      ),
    );
  }
}

class PansyPainter extends CustomPainter {
  final List<PansyParticle> particles;
  final double progress;
  final TextPainter _textPainter;

  PansyPainter({required this.particles, required this.progress})
    : _textPainter = TextPainter(
        text: const TextSpan(text: '🌸', style: TextStyle(fontSize: 40)),
        textDirection: TextDirection.ltr,
      )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (progress < p.delay) continue;

      final t = (progress - p.delay) / (1.0 - p.delay);
      final curve = Curves.easeOutCubic.transform(t);
      final offset = Offset.lerp(p.startOffset, p.endOffset, curve)!;

      final currentSize = p.size * curve;
      final scale = currentSize / 40.0;
      final currentRotation = p.rotation + (curve * p.totalSpin);

      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate(currentRotation);
      canvas.scale(scale);

      _textPainter.paint(
        canvas,
        Offset(-_textPainter.width / 2, -_textPainter.height / 2),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant PansyPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class PansyParticle {
  final Offset startOffset;
  final Offset endOffset;
  final double size;
  final double delay;
  final double rotation;
  final double totalSpin;

  PansyParticle({
    required this.startOffset,
    required Size screenSize,
    required Random random,
  }) : size = random.nextDouble() * 35 + 15,
       delay = random.nextDouble() * 0.3,
       rotation = random.nextDouble() * pi * 2,
       totalSpin = (random.nextDouble() - 0.5) * pi * 4,
       endOffset = Offset(
         random.nextDouble() * screenSize.width,
         random.nextDouble() * screenSize.height,
       );
}

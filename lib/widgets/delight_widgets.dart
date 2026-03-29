import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PhaseDelightOverlay extends StatelessWidget {
  final String phase;
  final VoidCallback onComplete;
  const PhaseDelightOverlay({
    super.key,
    required this.phase,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    String emoji = '✨';
    int count = 4;

    switch (phase) {
      case 'Follicular':
        emoji = '🧚';
        count = 4;
        break;
      case 'Ovulation':
        emoji = '✨';
        count = 5;
        break;
      case 'Luteal':
        emoji = '💫';
        count = 3;
        break;
      case 'Menstrual':
        emoji = '🌸';
        count = 4;
        break;
      case 'Period Logged':
        emoji = '🦋';
        count = 5;
        break;
      default:
        emoji = '✨';
        count = 4;
        break;
    }

    return IgnorePointer(
      child: Stack(
        children: List.generate(count, (index) {
          final random = Random();
          // Localized starting area around the center/bottom center where buttons usually are
          final startX = 0.45 + (random.nextDouble() - 0.5) * 0.2;
          final startY = 0.65 + (random.nextDouble() - 0.5) * 0.1;

          final driftX = (random.nextDouble() - 0.5) * 40;
          final driftY = -60 - random.nextDouble() * 40;

          return Positioned(
            left: MediaQuery.of(context).size.width * startX,
            top: MediaQuery.of(context).size.height * startY,
            child: Text(emoji, style: const TextStyle(fontSize: 22))
                .animate(
                  onComplete: (controller) {
                    if (index == count - 1) onComplete();
                  },
                )
                .fadeIn(duration: 150.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 200.ms,
                )
                .move(
                  begin: Offset.zero,
                  end: Offset(driftX, driftY),
                  duration: 700.ms,
                  curve: Curves.easeOutCubic,
                )
                .fadeOut(delay: 400.ms, duration: 300.ms),
          );
        }),
      ),
    );
  }
}

class FloatingSparkles extends StatelessWidget {
  final int count;
  final Color color;

  const FloatingSparkles({
    super.key,
    this.count = 12,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random();
    return IgnorePointer(
      child: Stack(
        children: List.generate(count, (index) {
          final x = random.nextDouble();
          final y = random.nextDouble();
          final size = 4.0 + random.nextDouble() * 6.0;
          final duration = 3 + random.nextInt(4);

          return Positioned(
            left: MediaQuery.of(context).size.width * x,
            top: MediaQuery.of(context).size.height * y,
            child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn(duration: duration.seconds)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.2, 1.2),
                  duration: duration.seconds,
                )
                .moveY(begin: 0, end: -30, duration: (duration + 2).seconds),
          );
        }),
      ),
    );
  }
}

class SparkleEffect extends StatelessWidget {
  final Widget child;
  final bool trigger;
  const SparkleEffect({super.key, required this.child, this.trigger = false});

  @override
  Widget build(BuildContext context) {
    if (!trigger) return child;

    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        ...List.generate(4, (index) {
          final angle = (index * 90) * (pi / 180);
          return Transform.translate(
            offset: Offset(cos(angle) * 20, sin(angle) * 20),
            child: IgnorePointer(
              child: const Text('✨', style: TextStyle(fontSize: 10))
                  .animate()
                  .fadeIn(duration: 150.ms)
                  .scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 300.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeOut(delay: 400.ms, duration: 200.ms),
            ),
          );
        }),
      ],
    );
  }
}

void showPhaseDelight(BuildContext context, String phase) {
  OverlayEntry? entry;
  entry = OverlayEntry(
    builder:
        (context) => PhaseDelightOverlay(
          phase: phase,
          onComplete: () {
            if (entry != null) {
              entry!.remove();
              entry = null;
            }
          },
        ),
  );
  Overlay.of(context).insert(entry!);

  // Safety removal after 3 seconds
  Future.delayed(const Duration(seconds: 3), () {
    if (entry != null) {
      entry!.remove();
      entry = null;
    }
  });
}

class AnimatedGlowBackground extends StatelessWidget {
  final Widget child;
  const AnimatedGlowBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background Gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF0F5), Color(0xFFFDEEF4), Color(0xFFF5F5FA)],
            ),
          ),
        ),
        // Animated Blobs (Positioned must be direct child of Stack)
        const Positioned(
          top: -100,
          left: -100,
          child: _GlowBlob(color: Color(0xFFFFD1DC), size: 400),
        ),
        const Positioned(
          bottom: -50,
          right: -50,
          child: _GlowBlob(color: Color(0xFFE6E6FA), size: 350),
        ),
        const Positioned(
          top: 200,
          right: -100,
          child: _GlowBlob(color: Color(0xFFF0F8FF), size: 300),
        ),

        // Content
        child,
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 100,
                  spreadRadius: 50,
                ),
              ],
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .move(
          begin: const Offset(-20, -20),
          end: const Offset(20, 20),
          duration: (8 + Random().nextInt(4)).seconds,
          curve: Curves.easeInOut,
        );
  }
}

class ShimmerButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double radius;

  const ShimmerButton({
    super.key,
    required this.child,
    this.onTap,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final body = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          IgnorePointer(ignoring: onTap != null, child: child),
          Positioned.fill(
            child: IgnorePointer(
              child: Container()
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(
                    duration: 2.seconds,
                    color: Colors.white.withValues(alpha: 0.2),
                    angle: pi / 4,
                  ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return body;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: body,
      ),
    );
  }
}

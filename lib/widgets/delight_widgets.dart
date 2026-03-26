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

    return Stack(
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
    );
  }
}

class FloatingSparkles extends StatelessWidget {
  const FloatingSparkles({super.key});

  @override
  Widget build(BuildContext context) {
    final random = Random();
    return Stack(
      children: List.generate(12, (index) {
        final x = random.nextDouble();
        final y = random.nextDouble();
        final size = 4.0 + random.nextDouble() * 6.0;
        final duration = 3 + random.nextInt(4);

        return Positioned(
          left: MediaQuery.of(context).size.width * x,
          top: MediaQuery.of(context).size.height * y,
          child:
              Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
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
          );
        }),
      ],
    );
  }
}

void showPhaseDelight(BuildContext context, String phase) {
  OverlayEntry? entry;
  entry = OverlayEntry(
    builder: (context) => PhaseDelightOverlay(
      phase: phase,
      onComplete: () {
        entry?.remove();
      },
    ),
  );
  Overlay.of(context).insert(entry);
}

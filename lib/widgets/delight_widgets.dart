import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

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
    final reduceMotion =
        MediaQuery.of(context).accessibleNavigation ||
        MediaQuery.of(context).disableAnimations;

    if (reduceMotion) {
      // Skip delight if reduced motion is requested, but notify caller we're done
      WidgetsBinding.instance.addPostFrameCallback((_) => onComplete());
      return const SizedBox.shrink();
    }

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

class FloatingFlowers extends StatelessWidget {
  final int count;

  const FloatingFlowers({super.key, this.count = 12});

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final reduceMotion =
        MediaQuery.of(context).accessibleNavigation ||
        MediaQuery.of(context).disableAnimations;

    return IgnorePointer(
      child: Stack(
        children: List.generate(count, (index) {
          final x = random.nextDouble();
          final y = random.nextDouble();
          final size = 12.0 + random.nextDouble() * 10.0;
          final duration = 15 + random.nextInt(15);
          final rotation = random.nextDouble() * pi * 2;

          final flower = Opacity(
            opacity: 0.4,
            child: Text('🌸', style: TextStyle(fontSize: size)),
          );

          if (kIsWeb || reduceMotion) {
            return Positioned(
              left: MediaQuery.of(context).size.width * x,
              top: MediaQuery.of(context).size.height * y,
              child: flower,
            );
          }

          return Positioned(
            left: MediaQuery.of(context).size.width * x,
            top: MediaQuery.of(context).size.height * y,
            child: flower
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .rotate(
                  begin: rotation,
                  end: rotation + pi / 4,
                  duration: duration.seconds,
                  curve: Curves.easeInOutSine,
                )
                .move(
                  begin: const Offset(-20, -20),
                  end: const Offset(20, 20),
                  duration: (duration + 5).seconds,
                  curve: Curves.easeInOutSine,
                )
                .fadeIn(duration: 2.seconds),
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
    this.count = 6, // Reduced from 12
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final random = Random();
    final reduceMotion =
        MediaQuery.of(context).accessibleNavigation ||
        MediaQuery.of(context).disableAnimations;

    return IgnorePointer(
      child: Stack(
        children: List.generate(count, (index) {
          final x = random.nextDouble();
          final y = random.nextDouble();
          final size = 6.0 + random.nextDouble() * 4.0;
          final duration = 4 + random.nextInt(4);

          final sparkle = Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          );

          if (kIsWeb) {
            return Positioned(
              left: MediaQuery.of(context).size.width * x,
              top: MediaQuery.of(context).size.height * y,
              child: sparkle,
            );
          }

          return Positioned(
            left: MediaQuery.of(context).size.width * x,
            top: MediaQuery.of(context).size.height * y,
            child: sparkle
                .animate(
                  target: reduceMotion ? 0 : null,
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .fadeIn(duration: duration.seconds)
                .scale(
                  begin: const Offset(0.6, 0.6),
                  end: const Offset(1.1, 1.1),
                  duration: duration.seconds,
                )
                .moveY(begin: 0, end: -20, duration: (duration + 1).seconds),
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

class NeonChimeBurst extends StatelessWidget {
  final VoidCallback onComplete;
  const NeonChimeBurst({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IgnorePointer(
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: List.generate(3, (index) {
            final delay = (index * 150).ms;
            return Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          index % 2 == 0
                              ? colorScheme.primary
                              : colorScheme.secondary,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (index % 2 == 0
                                ? colorScheme.primary
                                : colorScheme.secondary)
                            .withValues(alpha: 0.8),
                        blurRadius: 20,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                )
                .animate(onComplete: index == 2 ? (_) => onComplete() : null)
                .scale(
                  begin: const Offset(1, 1),
                  end: const Offset(40, 40),
                  duration: 800.ms,
                  delay: delay,
                  curve: Curves.easeOutCubic,
                )
                .fadeOut(duration: 600.ms, delay: delay + 200.ms);
          }),
        ),
      ),
    );
  }
}

void showNeonChime(BuildContext context) {
  OverlayEntry? entry;
  entry = OverlayEntry(
    builder:
        (context) => NeonChimeBurst(
          onComplete: () {
            entry?.remove();
            entry = null;
          },
        ),
  );
  Overlay.of(context).insert(entry!);
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
  final bool showSparkles;
  final bool showFlowers;

  const AnimatedGlowBackground({
    super.key,
    required this.child,
    this.showSparkles = false,
    this.showFlowers = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        // Background Gradient
        Container(decoration: AppTheme.getBackgroundDecoration(context)),

        // Animated Blobs
        Positioned(
          top: -100,
          left: -100,
          child: _GlowBlob(
            color: AppTheme.neuAccent,
            size: 350,
            durationOffset: 0,
            opacity: isDark ? 0.08 : 0.15,
          ),
        ),
        Positioned(
          bottom: -50,
          right: -50,
          child: _GlowBlob(
            color: AppTheme.neuAccentLight,
            size: 300,
            durationOffset: 4,
            opacity: isDark ? 0.06 : 0.12,
          ),
        ),
        Positioned(
          top: 300,
          right: -100,
          child: _GlowBlob(
            color: AppTheme.neuAccentSoft,
            size: 250,
            durationOffset: 8,
            opacity: isDark ? 0.05 : 0.1,
          ),
        ),

        if (showSparkles)
          const FloatingSparkles(count: 8, color: Colors.white70),

        if (showFlowers) const FloatingFlowers(count: 10),

        // Content
        child,
      ],
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final Color color;
  final double size;
  final int durationOffset;
  final double opacity;

  const _GlowBlob({
    required this.color,
    required this.size,
    required this.durationOffset,
    this.opacity = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.of(context).accessibleNavigation ||
        MediaQuery.of(context).disableAnimations;

    final blob = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: kIsWeb ? 50 : 100,
            spreadRadius: kIsWeb ? 25 : 50,
          ),
        ],
      ),
    );

    if (kIsWeb) return blob;

    return blob
        .animate(
          target: reduceMotion ? 0 : null,
          onPlay: (c) => c.repeat(reverse: true),
        )
        .move(
          begin: const Offset(-20, -20),
          end: const Offset(20, 20),
          duration: (15 + durationOffset).seconds,
          curve: Curves.easeInOutSine,
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
    this.radius = AppDesignTokens.radiusLG,
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
          boxShadow: AppTheme.neuShadows(
            isDark: Theme.of(context).brightness == Brightness.dark,
            size: ShadowSize.button,
          ),
        ),
        child: body,
      ),
    );
  }
}

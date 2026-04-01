import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final double? opacity;
  final double? blur;
  final Color? borderColor;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.radius,
    this.padding,
    this.opacity,
    this.blur,
    this.borderColor,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderRadius = BorderRadius.circular(radius ?? 24);
    final effectiveOpacity = opacity ?? (isDark ? 0.2 : 0.4);
    final effectiveBlur = blur ?? 8.0;

    Widget container = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: effectiveBlur, sigmaY: effectiveBlur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(effectiveOpacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor ??
                  (isDark ? Colors.white : theme.colorScheme.primary)
                      .withOpacity(0.15),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: container,
      );
    }

    return container;
  }
}


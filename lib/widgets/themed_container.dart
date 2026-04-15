import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';
import '../utils/app_theme.dart';

enum ContainerType { glass, neu, elevated, simple }

enum NeuStyle { flat, concave, convex, embossed }

class ThemedContainer extends StatelessWidget {
  final Widget child;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final ContainerType type;
  final Color? color;
  final Border? border;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final double? blur;
  final double? opacity;
  final Gradient? gradient;
  final bool isSelected;
  final NeuStyle style;
  final double? width;
  final double? height;

  const ThemedContainer({
    super.key,
    required this.child,
    this.radius,
    this.padding,
    this.margin,
    this.type = ContainerType.simple,
    this.color,
    this.border,
    this.borderColor,
    this.boxShadow,
    this.onTap,
    this.blur,
    this.opacity,
    this.gradient,
    this.isSelected = false,
    this.style = NeuStyle.flat,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(
      radius ?? AppDesignTokens.radiusLG,
    );
    final isHighPerf = context.select<StorageService, bool>(
      (StorageService s) => s.isHighPerformanceMode,
    );

    Widget container;

    switch (type) {
      case ContainerType.glass:
        final effectiveBlur = blur ?? 8.0;
        final effectiveOpacity = opacity ?? (context.isDarkMode ? 0.2 : 0.4);
        final bool shouldSkipBlur = isHighPerf;

        final glassContent = Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (color ?? context.surface).withValues(
              alpha:
                  isHighPerf
                      ? effectiveOpacity
                      : (effectiveOpacity + 0.2).clamp(0.0, 1.0),
            ),
            borderRadius: borderRadius,
            border:
                border ??
                (borderColor != null
                    ? Border.all(color: borderColor!, width: 1)
                    : Border.all(
                      color: (context.isDarkMode
                              ? Colors.white
                              : AppTheme.neuAccent)
                          .withValues(alpha: 0.1),
                      width: 1,
                    )),
          ),
          child: child,
        );

        if (shouldSkipBlur) {
          container = ClipRRect(
            borderRadius: borderRadius,
            child: glassContent,
          );
        } else {
          container = RepaintBoundary(
            child: ClipRRect(
              borderRadius: borderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: effectiveBlur,
                  sigmaY: effectiveBlur,
                ),
                child: glassContent,
              ),
            ),
          );
        }
        break;

      case ContainerType.neu:
        container = Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color:
                gradient != null
                    ? null
                    : (color ??
                        (context.isDarkMode
                            ? AppTheme.darkSurface
                            : AppTheme.neuBg)),
            gradient: gradient,
            border:
                border ??
                (borderColor != null
                    ? Border.all(color: borderColor!, width: 1.5)
                    : null),
            boxShadow:
                boxShadow ??
                AppTheme.neuShadows(
                  isDark: context.isDarkMode,
                  size: ShadowSize.card,
                ),
          ),
          child: child,
        );
        break;

      case ContainerType.elevated:
        container = Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: color ?? context.surface,
            border: border,
            boxShadow:
                boxShadow ??
                [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).shadowColor.withValues(alpha: isHighPerf ? 0.08 : 0.05),
                    blurRadius: isHighPerf ? 15 : 4,
                    offset: Offset(0, isHighPerf ? 8 : 2),
                  ),
                ],
          ),
          child: child,
        );
        break;

      case ContainerType.simple:
        container = Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: color ?? context.surface,
            border: border,
            boxShadow: boxShadow,
            gradient: gradient,
          ),
          child: child,
        );
        break;
    }

    if (margin != null) {
      container = Padding(padding: margin!, child: container);
    }

    if (onTap != null) {
      return Semantics(
        button: true,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap!();
          },
          behavior: HitTestBehavior.opaque,
          child: container,
        ),
      );
    }

    return container;
  }
}

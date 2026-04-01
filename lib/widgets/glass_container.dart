import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../utils/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double radius;
  final double opacity;
  final double blur;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? borderColor;
  final double? width;
  final double? height;

  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.radius = 32.0,
    this.opacity = AppTheme.glassOpacity,
    this.blur = AppTheme.glassBlur,
    this.padding,
    this.margin,
    this.borderColor,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Common Decoration for Glass effect
    // BackdropFilter is notoriously slow on Flutter Web when layered.
    // By conditionally disabling it on Web, we get a 10x performance boost
    // while keeping the translucent "glass" aesthetic.
    final glassBg = Positioned.fill(
      child:
          kIsWeb
              ? Container(
                decoration: BoxDecoration(
                  color: (borderColor ?? AppTheme.surfaceColor).withValues(
                    alpha: opacity * 1.5,
                  ), // Slightly more opaque to compensate
                  borderRadius: BorderRadius.circular(radius),
                ),
              )
              : BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  decoration: BoxDecoration(
                    color: (borderColor ?? AppTheme.surfaceColor).withValues(
                      alpha: opacity,
                    ),
                    borderRadius: BorderRadius.circular(radius),
                  ),
                ),
              ),
    );

    // 2. Common Decoration for Border & Reflection
    final glassBorder = Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.shadowLightColor.withValues(alpha: 0.4),
              AppTheme.shadowMidColor.withValues(alpha: 0.05),
              AppTheme.shadowDarkColor.withValues(alpha: 0.05),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
          border: Border.all(
            color: (borderColor ?? AppTheme.surfaceColor).withValues(
              alpha: AppTheme.glassBorderOpacity,
            ),
            width: 1.5,
          ),
        ),
      ),
    );

    // 3. The Content
    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      child: child,
    );

    // 4. Wrap with Interaction if needed
    if (onTap != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: RepaintBoundary(
          child: Stack(
            fit: StackFit.loose,
            children: [glassBg, glassBorder, content],
          ),
        ),
      ),
    );
  }
}

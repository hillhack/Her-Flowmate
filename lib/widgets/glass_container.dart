import 'dart:ui';
import 'package:flutter/material.dart';
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
    final glassBg = Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: (borderColor ?? Colors.white).withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );

    // 2. Common Decoration for Border
    final glassBorder = Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: (borderColor ?? Colors.white).withOpacity(0.2),
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
        child: Stack(
          fit: StackFit.loose,
          children: [
            glassBg,
            glassBorder,
            content,
          ],
        ),
      ),
    );
  }
}
